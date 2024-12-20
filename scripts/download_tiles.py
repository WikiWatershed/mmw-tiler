import asyncio
import httpx
import aiofiles
import aiofiles.os
import hashlib
import os
from pathlib import Path

# This is a version of the main loop from the 'mosaic.ipnb' notebook, but tweaked to run from
# the command line. It will download all tiles for the given zoom_levels.
# The parameters are hard-coded at the top of the file here, not passed in (since that's easier
# to write and keeps it more similar to the notebook).

COLORMAP = "%7B%220%22%3A%20%22%23000000%22%2C%20%221%22%3A%20%22%23419bdf%22%2C%20%222%22%3A%20%22%23397d49%22%2C%20%223%22%3A%20%22%23000000%22%2C%20%224%22%3A%20%22%237a87c6%22%2C%20%225%22%3A%20%22%23e49635%22%2C%20%226%22%3A%20%22%23000000%22%2C%20%227%22%3A%20%22%23c4281b%22%2C%20%228%22%3A%20%22%23a59b8f%22%2C%20%229%22%3A%20%22%23a8ebff%22%2C%20%2210%22%3A%20%22%23616161%22%2C%20%2211%22%3A%20%22%23e3e2c3%22%7D"

# the 2023 one
tile_url_template = "https://tiler.staging.modelmywatershed.org/mosaicjson/mosaics/fec54b55-5e75-4c6d-ac47-41579d722dab/tiles/{z}/{x}/{y}"

tiler_url = "https://tiler.staging.modelmywatershed.org"
tiler_lambda_function_url = "https://2empcsyg6p3r53jhbp6v2ovsia0awpdn.lambda-url.us-west-2.on.aws"
zoom_levels = [4,5]
scales = ["",]  # Options are "@2x", "@1x", and "" (which also produces 1x tiles, but with different hashes)
output_dir = "tiles-lambda"


# From here: https://stackoverflow.com/a/66289885
from functools import wraps
def request_concurrency_limit_decorator(limit=3):
    # Bind the default event loop 
    sem = asyncio.Semaphore(limit)
    def executor(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            async with sem:
                return await func(*args, **kwargs)
        return wrapper
    return executor


lambda_tile_url_template = tile_url_template.replace(tiler_url,tiler_lambda_function_url)


@request_concurrency_limit_decorator(limit=30)
async def download_tile(tile_url_template: str, z: int, x: int, y: int):
    base_tile_url = tile_url_template.replace("{z}", str(z)).replace("{x}", str(x)).replace("{y}", str(y))
    mosaic_path = base_tile_url.split("/mosaicjson/mosaics/", maxsplit=1)[1]
    for scale in scales:
        params = f"{scale}.png?colormap={COLORMAP}"
        tile_url = f"{base_tile_url}{params}"
        mosaic_hash = hashlib.sha256(params.encode()).hexdigest()
        local_path = f"{output_dir}/{mosaic_path}/{mosaic_hash}.png"
        if not Path(local_path).exists():
            async with httpx.AsyncClient() as client:
                print(f"requesting tile {tile_url}")
                r = await client.get(tile_url, timeout=httpx.Timeout(5.0, read=900))
                match r.status_code:
                    case httpx.codes.OK:
                        await aiofiles.os.makedirs(f"{output_dir}/{mosaic_path}", exist_ok=True)
                        async with aiofiles.open(local_path, "wb") as f:
                            await f.write(r.content)
                    case httpx.codes.NOT_FOUND:
                        await aiofiles.os.makedirs(f"{output_dir}/{mosaic_path}", exist_ok=True)
                        await aiofiles.open(local_path, "w+")
                    case _:
                        return f"Error: {tile_url} => {r.status_code}: {r.text}"

@request_concurrency_limit_decorator(limit=1)
async def download_tiles_for_zoomlevel(zoom_level):
    print(f"Downloading tiles for zoomlevel {zoom_level}")
    zxy_tuples = [(zoom_level, x, y) for x in range(0, 2**zoom_level) for y in range(0, 2**zoom_level)]
    return await asyncio.gather(*(download_tile(lambda_tile_url_template, *args) for args in zxy_tuples))

async def download_tiles():
    return await asyncio.gather(*(download_tiles_for_zoomlevel(z) for z in zoom_levels))

os.makedirs(output_dir, exist_ok=True)
result = asyncio.run(download_tiles())
print(f"Failures: {[r for r in result if r]}")
