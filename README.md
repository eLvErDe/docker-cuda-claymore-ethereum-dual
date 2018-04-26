# nvidia-docker image for Claymore's Ethereum dual miner

This image build [Claymore's Ethereum dual miner] from Claymore's Google Drive.
It requires a CUDA compatible docker implementation so you should probably go
for [nvidia-docker].
It has also been tested successfully on [Mesos] 1.5.0.

## Build images

```
git clone https://github.com/eLvErDe/docker-cuda-claymore-ethereum-dual.git
cd docker-cuda-claymore-ethereum-dual
docker build -t cuda-claymore-ethereum-dual:11.7 .
```

## Publish it somewhere

```
docker tag cuda-claymore-ethereum-dual:11.7 docker.domain.com/mining/cuda-claymore-ethereum-dual:11.7
docker push docker.domain.com/mining/cuda-claymore-ethereum-dual:11.7
```

## Test it (using dockerhub published image)

```
nvidia-docker pull acecile/cuda-claymore-ethereum-dual:11.7
nvidia-docker run -it --rm acecile/cuda-claymore-ethereum-dual:11.7 /root/claymore/ethdcrminer64
```

An example command line to mine using ethermine.org (on my account, you can use it to actually mine something for real if you haven't choose your pool yet):
```
nvidia-docker run -it --rm --name cuda-claymore-ethereum-dual acecile/cuda-claymore-ethereum-dual:11.7 /root/claymore/ethdcrminer64 -epool eu1.ethermine.org:4444 -ewal 0x5d8dd9ec9e16b39b5fb1f805b58b3ce5a572a2dd -eworker rig1
```

Ouput will looks like:
```

����������������������������������������������������������������ͻ
�                Claymore's Dual GPU Miner - v11.7               �
�              ETH + DCR/SIA/LBC/PASC/BLAKE2S/KECCAK             �
����������������������������������������������������������������ͼ

ETH: No pools specified! Specify at least one valid pool in "-epool" parameter. 
```

## Background job running forever

```
nvidia-docker run -dt --restart=unless-stopped -p 4068:4068 --name cuda-claymore-ethereum-dual acecile/cuda-claymore-ethereum-dual:11.7 /root/claymore/ethdcrminer64 -epool eu1.ethermine.org:4444 -ewal 0x5d8dd9ec9e16b39b5fb1f805b58b3ce5a572a2dd -eworker rig1 -mport 4068
```

You can check the output using `docker logs cuda-claymore-ethereum-dual -f`


## Use it with Mesos/Marathon

Edit `mesos_marathon.json` to replace mining pool parameter, change application path as well as docker image address (if you dont want to use public docker image provided).
Then simply run (adapt application name here too):

```
curl -X PUT -u marathon\_username:marathon\_password --header 'Content-Type: application/json' "http://marathon.domain.com:8080/v2/apps/mining/cuda-claymore-ethereum-dual?force=true" -d@./mesos\_marathon.json
```

You can check CUDA usage on the mesos slave (executor host) by running `nvidia-smi` there:

```
Thu Apr 26 21:24:04 2018       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 390.42                 Driver Version: 390.42                    |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  GeForce GTX 1080    On   | 00000000:03:00.0 Off |                  N/A |
| 49%   73C    P2   118W / 120W |   2679MiB /  8119MiB |    100%      Default |
+-------------------------------+----------------------+----------------------+
|   1  GeForce GTX 108...  On   | 00000000:04:00.0 Off |                  N/A |
| 46%   66C    P2   203W / 200W |   2717MiB / 11178MiB |    100%      Default |
+-------------------------------+----------------------+----------------------+
|   2  GeForce GTX 108...  On   | 00000000:05:00.0 Off |                  N/A |
| 53%   70C    P2   192W / 200W |   2717MiB / 11178MiB |    100%      Default |
+-------------------------------+----------------------+----------------------+
|   3  GeForce GTX 108...  On   | 00000000:06:00.0 Off |                  N/A |
| 35%   62C    P2   197W / 200W |   2717MiB / 11178MiB |    100%      Default |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|    0      3134      C   /root/claymore/ethdcrminer64                2661MiB |
|    1      3134      C   /root/claymore/ethdcrminer64                2699MiB |
|    2      3134      C   /root/claymore/ethdcrminer64                2699MiB |
|    3      3134      C   /root/claymore/ethdcrminer64                2699MiB |
+-----------------------------------------------------------------------------+
```

[Claymore's Ethereum dual miner]: https://bitcointalk.org/index.php?topic=1433925.0
[nvidia-docker]: https://github.com/NVIDIA/nvidia-docker
[Mesos]: http://mesos.apache.org/documentation/latest/gpu-support/
