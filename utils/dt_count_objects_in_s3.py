import os
import boto3
from botocore.exceptions import ClientError, NoCredentialsError, EndpointConnectionError


def _aws_credentials_get_from_env():
    name = os.environ.get('DDH_AWS_NAME')
    key_id = os.environ.get('DDH_AWS_KEY_ID')
    secret = os.environ.get('DDH_AWS_SECRET')
    return name, key_id, secret


def _get_bucket_objects_keys(cli, b, p='') -> dict:
    """ returns a filled dict, an empty dict or None """

    d = {}
    try:
        rsp = cli.list_objects_v2(Bucket=b,
                                  Prefix=p,
                                  MaxKeys=10000)
        contents = rsp['Contents']
        for each in contents:
            d[each['Key']] = each['Size']
        return d
    except KeyError:
        # empty bucket, no rsp['Contents']
        # it can happen for *.txt at logger_folder
        # it can happen for *.lid, *.csv, *.gps at track folder
        # l_e_('[ AWS ] error -> {}'.format(ke))
        return {}


def _aws_is_s3_connection_ok(aws_key_id, aws_secret, bkt_name):
    cli = boto3.client('s3',
                       region_name='us-east-1',
                       aws_access_key_id=aws_key_id,
                       aws_secret_access_key=aws_secret)

    try:
        cli.head_bucket(Bucket=bkt_name)
        return cli
    except (ClientError, NoCredentialsError) as e:
        print('[ AWS ] error S3', e)


def s3_count(bkt):
    _, a_id, sec = _aws_credentials_get_from_env()
    cli = _aws_is_s3_connection_ok(a_id, sec, bkt)
    if not cli:
        return

    try:
        folders = cli.list_objects(Bucket=bkt, Delimiter='/')
        for each_folder in folders.get('CommonPrefixes'):
            fol = each_folder.get('Prefix')
            o_k = _get_bucket_objects_keys(cli, bkt, p=fol)
            s = '{}\tobjects in {}/{}'.format(len(o_k), bkt, fol)
            print(s.format(fol, len(o_k)))

    except (ClientError, EndpointConnectionError, Exception) as ex:
        print(ex)


if __name__ == '__main__':
    bkt_name = 'bkt-cfa'
    s3_count(bkt_name)
