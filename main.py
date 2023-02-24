from datetime import datetime
import sys
import time
import urllib3

import requests


if __name__ == "__main__":
    url = sys.argv[1]
    print(f"Querying {url}...")
    trials = 0
    failures = 0
    while True:
        trials += 1
        try:
            resp = requests.get(url, timeout=5)
            print(f"{datetime.utcnow().isoformat()} Success {resp.status_code}; {failures} failures in {trials} trials")
        except (requests.RequestException, urllib3.exceptions.ReadTimeoutError) as e:
            failures += 1
            print(f"{datetime.utcnow().isoformat()} {type(e).__name__}: {e}")
        time.sleep(0.5)
