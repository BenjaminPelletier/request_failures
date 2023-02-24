# Request failures reproduction

I [noticed](https://github.com/interuss/monitoring/issues/28), circa beginning of 2023, that the continuous integration tests for [a project I work on](https://github.com/interuss/monitoring) would occasionally fail because a request between the containers would time out.  A lot of logging revealed that this was always a timeout when attempting to establish the connection -- the receiving container's logs would never indicate that a request had been made.  At first, I assumed this problem was due to logic in a new service I had introduced.  However, this repo is the result of a concerted attempt to simplify down the system producing the timeouts (which were much, much more frequent on my development laptop at the time) and the discovery that merely sending vanilla HTTP requests using the Python `requests` library to an nginx container was sufficient to reproduce the problem on my development machine (MacOS Ventura 13.2.1).  I now believe that the reason this issue started to appear for me in early 2023 is that my new service enormously increased the volume of HTTP requests between containers during CI tests, and this issue just seems to appear randomly with a very low probability on a per-request basis.

When I created this repo, `run_containers_host_docker_internal.sh` would indicate connection timeouts for almost 10% of requests, and the incidence seemed random.  `run_containers_default_bridge.sh` produced no errors for a few hundred requests, but then switching back to `run_containers_host_docker_internal.sh` again produced errors.  `run_containers_custom_bridge.sh` also produced no errors, however after running that test, `run_containers_host_docker_internal.sh` no longer produced any errors even after 1500+ requests.

There seems to be a strong similarity of this problem to [this issue](https://github.com/docker/for-win/issues/8861) (even though I have primarily observed the problem on MacOS, and partially on Linux in GitHub Actions cloud).

Since I am no longer able to reliably reproduce the issue on my laptop, this is a sample of the console output when I was able to reliably reproduce the issue (using an earlier version of `run_containers_host_docker_internal.sh`):

```
Querying http://host.docker.internal:8075...
2023-02-24T19:47:35.004039 Success 200; 0 failures in 1 trials
2023-02-24T19:47:35.519517 Success 200; 0 failures in 2 trials
2023-02-24T19:47:36.030139 Success 200; 0 failures in 3 trials
2023-02-24T19:47:36.543102 Success 200; 0 failures in 4 trials
2023-02-24T19:47:37.053821 Success 200; 0 failures in 5 trials
2023-02-24T19:47:42.569479 ConnectTimeout: HTTPConnectionPool(host='host.docker.internal', port=8075): Max retries exceeded with url: / (Caused by ConnectTimeoutError(<urllib3.connection.HTTPConnection object at 0x7ffaa10bde80>, 'Connection to host.docker.internal timed out. (connect timeout=5)'))
2023-02-24T19:47:43.075936 Success 200; 1 failures in 7 trials
2023-02-24T19:47:43.582825 Success 200; 1 failures in 8 trials
2023-02-24T19:47:44.093673 Success 200; 1 failures in 9 trials
2023-02-24T19:47:44.603848 Success 200; 1 failures in 10 trials
2023-02-24T19:47:45.085069 Success 200; 1 failures in 11 trials
2023-02-24T19:47:45.593181 Success 200; 1 failures in 12 trials
2023-02-24T19:47:46.104696 Success 200; 1 failures in 13 trials
2023-02-24T19:47:46.613163 Success 200; 1 failures in 14 trials
2023-02-24T19:47:52.128679 ConnectTimeout: HTTPConnectionPool(host='host.docker.internal', port=8075): Max retries exceeded with url: / (Caused by ConnectTimeoutError(<urllib3.connection.HTTPConnection object at 0x7ffaa10bd940>, 'Connection to host.docker.internal timed out. (connect timeout=5)'))
2023-02-24T19:47:52.637575 Success 200; 2 failures in 16 trials
2023-02-24T19:47:53.148121 Success 200; 2 failures in 17 trials
2023-02-24T19:47:58.660255 ConnectTimeout: HTTPConnectionPool(host='host.docker.internal', port=8075): Max retries exceeded with url: / (Caused by ConnectTimeoutError(<urllib3.connection.HTTPConnection object at 0x7ffaa106f160>, 'Connection to host.docker.internal timed out. (connect timeout=5)'))
2023-02-24T19:47:59.171013 Success 200; 3 failures in 19 trials
2023-02-24T19:47:59.679863 Success 200; 3 failures in 20 trials
2023-02-24T19:48:05.190854 ConnectTimeout: HTTPConnectionPool(host='host.docker.internal', port=8075): Max retries exceeded with url: / (Caused by ConnectTimeoutError(<urllib3.connection.HTTPConnection object at 0x7ffaa106f130>, 'Connection to host.docker.internal timed out. (connect timeout=5)'))
2023-02-24T19:48:05.701672 Success 200; 4 failures in 22 trials
2023-02-24T19:48:06.210934 Success 200; 4 failures in 23 trials
2023-02-24T19:48:06.719506 Success 200; 4 failures in 24 trials
2023-02-24T19:48:07.231453 Success 200; 4 failures in 25 trials
2023-02-24T19:48:07.743770 Success 200; 4 failures in 26 trials
2023-02-24T19:48:13.259157 ConnectTimeout: HTTPConnectionPool(host='host.docker.internal', port=8075): Max retries exceeded with url: / (Caused by ConnectTimeoutError(<urllib3.connection.HTTPConnection object at 0x7ffaa1076400>, 'Connection to host.docker.internal timed out. (connect timeout=5)'))
2023-02-24T19:48:13.773371 Success 200; 5 failures in 28 trials
2023-02-24T19:48:14.286703 Success 200; 5 failures in 29 trials
2023-02-24T19:48:14.799049 Success 200; 5 failures in 30 trials
2023-02-24T19:48:15.277471 Success 200; 5 failures in 31 trials
2023-02-24T19:48:15.796020 Success 200; 5 failures in 32 trials
2023-02-24T19:48:16.305439 Success 200; 5 failures in 33 trials
2023-02-24T19:48:16.814427 Success 200; 5 failures in 34 trials
2023-02-24T19:48:17.325436 Success 200; 5 failures in 35 trials
2023-02-24T19:48:22.837284 ConnectTimeout: HTTPConnectionPool(host='host.docker.internal', port=8075): Max retries exceeded with url: / (Caused by ConnectTimeoutError(<urllib3.connection.HTTPConnection object at 0x7ffaa10763d0>, 'Connection to host.docker.internal timed out. (connect timeout=5)'))
2023-02-24T19:48:23.348106 Success 200; 6 failures in 37 trials
2023-02-24T19:48:23.860974 Success 200; 6 failures in 38 trials
2023-02-24T19:48:24.370057 Success 200; 6 failures in 39 trials
2023-02-24T19:48:24.880093 Success 200; 6 failures in 40 trials
2023-02-24T19:48:25.389325 Success 200; 6 failures in 41 trials
2023-02-24T19:48:25.907467 Success 200; 6 failures in 42 trials
2023-02-24T19:48:26.416824 Success 200; 6 failures in 43 trials
2023-02-24T19:48:26.927267 Success 200; 6 failures in 44 trials
2023-02-24T19:48:27.438055 Success 200; 6 failures in 45 trials
2023-02-24T19:48:27.949956 Success 200; 6 failures in 46 trials
2023-02-24T19:48:28.459526 Success 200; 6 failures in 47 trials
2023-02-24T19:48:28.973783 Success 200; 6 failures in 48 trials
2023-02-24T19:48:29.486155 Success 200; 6 failures in 49 trials
2023-02-24T19:48:29.994972 Success 200; 6 failures in 50 trials
2023-02-24T19:48:30.504448 Success 200; 6 failures in 51 trials
2023-02-24T19:48:31.016509 Success 200; 6 failures in 52 trials
2023-02-24T19:48:31.528099 Success 200; 6 failures in 53 trials
2023-02-24T19:48:32.041766 Success 200; 6 failures in 54 trials
2023-02-24T19:48:32.554414 Success 200; 6 failures in 55 trials
2023-02-24T19:48:33.064597 Success 200; 6 failures in 56 trials
2023-02-24T19:48:33.573888 Success 200; 6 failures in 57 trials
2023-02-24T19:48:34.086248 Success 200; 6 failures in 58 trials
2023-02-24T19:48:34.594375 Success 200; 6 failures in 59 trials
2023-02-24T19:48:35.107118 Success 200; 6 failures in 60 trials
2023-02-24T19:48:35.618769 Success 200; 6 failures in 61 trials
2023-02-24T19:48:36.128439 Success 200; 6 failures in 62 trials
2023-02-24T19:48:36.640142 Success 200; 6 failures in 63 trials
2023-02-24T19:48:37.152311 Success 200; 6 failures in 64 trials
2023-02-24T19:48:37.661992 Success 200; 6 failures in 65 trials
2023-02-24T19:48:38.177874 Success 200; 6 failures in 66 trials
2023-02-24T19:48:38.687593 Success 200; 6 failures in 67 trials
2023-02-24T19:48:39.199017 Success 200; 6 failures in 68 trials
2023-02-24T19:48:39.709196 Success 200; 6 failures in 69 trials
2023-02-24T19:48:45.184625 ConnectTimeout: HTTPConnectionPool(host='host.docker.internal', port=8075): Max retries exceeded with url: / (Caused by ConnectTimeoutError(<urllib3.connection.HTTPConnection object at 0x7ffaa1076730>, 'Connection to host.docker.internal timed out. (connect timeout=5)'))
2023-02-24T19:48:45.695720 Success 200; 7 failures in 71 trials
2023-02-24T19:48:46.204114 Success 200; 7 failures in 72 trials
2023-02-24T19:48:46.716494 Success 200; 7 failures in 73 trials
2023-02-24T19:48:47.225138 Success 200; 7 failures in 74 trials
2023-02-24T19:48:47.735435 Success 200; 7 failures in 75 trials
2023-02-24T19:48:48.246333 Success 200; 7 failures in 76 trials
2023-02-24T19:48:48.755438 Success 200; 7 failures in 77 trials
2023-02-24T19:48:49.267821 Success 200; 7 failures in 78 trials
2023-02-24T19:48:49.778544 Success 200; 7 failures in 79 trials
2023-02-24T19:48:50.288014 Success 200; 7 failures in 80 trials
2023-02-24T19:48:50.795860 Success 200; 7 failures in 81 trials
2023-02-24T19:48:51.302373 Success 200; 7 failures in 82 trials
2023-02-24T19:48:51.810687 Success 200; 7 failures in 83 trials
2023-02-24T19:48:52.316811 Success 200; 7 failures in 84 trials
2023-02-24T19:48:57.829706 ConnectTimeout: HTTPConnectionPool(host='host.docker.internal', port=8075): Max retries exceeded with url: / (Caused by ConnectTimeoutError(<urllib3.connection.HTTPConnection object at 0x7ffaa10bdbb0>, 'Connection to host.docker.internal timed out. (connect timeout=5)'))
2023-02-24T19:48:58.341446 Success 200; 8 failures in 86 trials
2023-02-24T19:48:58.849363 Success 200; 8 failures in 87 trials
2023-02-24T19:48:59.355863 Success 200; 8 failures in 88 trials
2023-02-24T19:48:59.866555 Success 200; 8 failures in 89 trials
2023-02-24T19:49:00.376259 Success 200; 8 failures in 90 trials
2023-02-24T19:49:00.884663 Success 200; 8 failures in 91 trials
2023-02-24T19:49:01.395283 Success 200; 8 failures in 92 trials
2023-02-24T19:49:01.903621 Success 200; 8 failures in 93 trials
2023-02-24T19:49:07.413766 ConnectTimeout: HTTPConnectionPool(host='host.docker.internal', port=8075): Max retries exceeded with url: / (Caused by ConnectTimeoutError(<urllib3.connection.HTTPConnection object at 0x7ffaa10bdb50>, 'Connection to host.docker.internal timed out. (connect timeout=5)'))
2023-02-24T19:49:07.925805 Success 200; 9 failures in 95 trials
2023-02-24T19:49:08.432666 Success 200; 9 failures in 96 trials
2023-02-24T19:49:08.938629 Success 200; 9 failures in 97 trials
2023-02-24T19:49:09.445661 Success 200; 9 failures in 98 trials
2023-02-24T19:49:09.954722 Success 200; 9 failures in 99 trials
2023-02-24T19:49:10.465720 Success 200; 9 failures in 100 trials
2023-02-24T19:49:10.974511 Success 200; 9 failures in 101 trials
2023-02-24T19:49:16.450513 ConnectTimeout: HTTPConnectionPool(host='host.docker.internal', port=8075): Max retries exceeded with url: / (Caused by ConnectTimeoutError(<urllib3.connection.HTTPConnection object at 0x7ffaa1084730>, 'Connection to host.docker.internal timed out. (connect timeout=5)'))
2023-02-24T19:49:16.956578 Success 200; 10 failures in 103 trials
2023-02-24T19:49:17.462607 Success 200; 10 failures in 104 trials
2023-02-24T19:49:17.969973 Success 200; 10 failures in 105 trials
2023-02-24T19:49:18.479509 Success 200; 10 failures in 106 trials
2023-02-24T19:49:18.987952 Success 200; 10 failures in 107 trials
```