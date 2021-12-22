from __future__ import print_function

import json
import boto3
from botocore.exceptions import ClientError
import os
from dateutil import parser

print('Loading function')

def newest_image(list_of_images):
    latest = None

    for image in list_of_images:
        if not latest:
            latest = image
            continue

        if parser.parse(image['CreationDate']) > parser.parse(latest['CreationDate']):
            latest = image

    return latest

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))

    clientEc2 = boto3.client('ec2')

    ListOfAmiTags=json.loads(os.environ["ami_tag_value"])
    for tag_value in ListOfAmiTags:
        print("Loading " + tag_value + " update")
        
        ListTaggedAmis = clientEc2.describe_images(Filters=[
            {
                'Name':'tag:LaunchTemplateAmiManager', 
                'Values':[tag_value]
            },
        ])
        
        
        if not ListTaggedAmis:
            
            print("AMI NOT found (Tag: LaunchTemplateAmiManager=" + tag_value + ")")
            
        else:
            
            LatestAmiSnapshot = newest_image(ListTaggedAmis['Images'])['ImageId']
            LaunchTemplateName = clientEc2.describe_launch_templates(
                Filters=[
                {
                    'Name': 'tag:LaunchTemplateAmiManager',
                    'Values':[tag_value]
                },
            ],
            )["LaunchTemplates"][0]["LaunchTemplateName"]
            
            if not LaunchTemplateName:
                print("Launch Template NOT found (Tag: LaunchTemplateAmiManager=" + tag_value + ")")
                
            else: 
                LatestLaunchTemplateVersion = clientEc2.describe_launch_template_versions(
                    LaunchTemplateName=LaunchTemplateName,
                    Versions=[
                        '$Latest',
                    ],
                )['LaunchTemplateVersions'][0]
                LatestAmiLaunchTemplate = LatestLaunchTemplateVersion['LaunchTemplateData']['ImageId']
                try: 
                    if (LatestAmiSnapshot != LatestAmiLaunchTemplate):
                        NewLaunchTemplateVersion = clientEc2.create_launch_template_version(
                        LaunchTemplateName=LaunchTemplateName,
                        SourceVersion='$Latest',
                        LaunchTemplateData={
                            'ImageId': LatestAmiSnapshot
                        }
                    )
                        print("A new launch template version (%s:%s) has been created with the latest AMI %s." % (LaunchTemplateName,NewLaunchTemplateVersion['LaunchTemplateVersion']['VersionNumber'],LatestAmiSnapshot))
                    else:
                        print("There is nothing to do. The latest Launch template Version (%s:%s) already uses the latest AMI %s." % (LaunchTemplateName,LatestLaunchTemplateVersion['VersionNumber'],LatestAmiSnapshot))
                except ClientError as e:
                    print(e)
            
            
    return "Successfully completed the AMI update for the selected launch templates."