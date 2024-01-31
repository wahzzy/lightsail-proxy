import yaml
import requests
import json
import os
# Update DNS Record
def update_dns_record():

    configs = {}
    # read config
    with open(f"{os.getcwd()}/../python/configs.yml", "r") as config_file:
        configs = yaml.safe_load(config_file)

    cloudflare_base_url = 'https://api.cloudflare.com/client/v4'

    headers = {"Authorization": f"Bearer {configs['cloudflare_token']}"}
    # res = requests.get(
    #     f'{cloudflare_base_url}/user/tokens/verify',
    #     headers=headers
    # )
    data = json.dumps({
        "content": configs['instance_ip'],
        "name": configs['domain'],
        "type": "A"
    })
    res = requests.put(
        f'{cloudflare_base_url}/zones/{configs["zone_id"]}/dns_records/{configs["dns_record_id"]}',
        headers=headers,
        data=data
    ).json()
    print(res)



if __name__ == "__main__":
    update_dns_record()