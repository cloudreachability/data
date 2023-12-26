# Cloud Endpoints

Cloud target endpoints for reachability research.

The repository contains the following files:

1. `cloudregions.updated.csv`

    Contains the list of cloud VM endpoints. The CSV dataset is in following format:
    ```    
    Endpoint URL, CloudProvider, Region, Location1 (City), Location2 (Country), Endpoint IP address;
    ```
    The CSV will be periodically updated. The VM endpoints are controlled by third-party providers such as [CloudPing](https://www.cloudping.cloud/), [CloudPingTest](https://cloudpingtest.com/), etc.
    
2. `pingTester.sh`

    The script pings the Endpoint IP addresses in the `cloudregions.updated.csv` and returns if they are available. Use this to check if the URLs are being served by the same servers since the data collection.
    
    Usage:
    ```
    ./pingTester.sh cloudregions.updated.csv
    ```

3. `cloudURLtester.sh`

    In case the IP addresses are unreachable in step 2, or you want to refresh the IP addresses before triggering measurements, use this script to send HTTP GET requests to URL and record remote IP address.
    
    The script expects a modified version of `cloudregions.updated.csv` as input without the IP address (last) column.
    ```    
    Endpoint URL, CloudProvider, Region, Location1 (City), Location2 (Country);
    ```
    
    To transform the `cloudregions.updated.csv` to this format, you can use the following `BASH` one-liner:
    
    ```
    awk -F, 'BEGIN {OFS=","} {NF--; print $0 ";" }' cloudregions.updated.csv > cloudregions.csv
    ```
    
    Following this, you can recreate the `cloudregions.updated.csv` with up-to-date server IP addresses via:
    
    ```
    ./cloudURLtester.sh cloudregions.csv
    ``` 
    
    which should create `cloudregions.updated_$timezone.csv`
