# Cloudformation Gamer Setup with AMD, NICE DCV and Steam

This template builds the infrastructure and Ubuntu 18.04 based AMI
with Nice DCV, AMD drivers for g4ad machines and installs Steam for linux.
It utilizes Spot Instances.

It creates or recovers an EBS volume from a snapshot and mounts it to /home/gamer and using lifecycle hooks and event rules 
attempts to snapshot the EBS volume on tear down.

This stack also creates an IAM user that has permissions to only change 
the desired capacity of the AutoScaling Group that manages the instances.

Their credentials are in the outputs of the Cloudformation stack.

Your CIDR is required to limit access to your current location.

The gamer user on linux is given automatic login and no password required Nice DCV.  Alter the template if that is a problem.

**!!!!!Important!!!!!**

Machines must be spun down by either a spot instance terminating event or
the AutoScaling Group changing its capacity.  Otherwise no snapshotting or automatic
EBS mounting will occur.

Please do not rely on snapshotting to work! I am not responsible for lost data.

There is no snapshot cleanup at this time. You will have to manually remove old snapshots.
If anything fails you may have old EBS volumes laying around.

**Your AWS bill may get large! I suggest setting up billing alerts, your bill is not my problem.**

This comes with no guarantees!

## Required
- awscli
- Nice DCV client
- A quota increase on your AWS account for g4ad spot instances


## Launching

Generate a parameters file.
```bash
./addcidr.sh > myparameters.json
```

Create a password for the gamer user

```bash
aws secretsmanager create-secret --name gamer-secret-password --secret-string 'yourpasswordhere'
```
Password gets set every time a machine starts so you can update the password anytime before a scale out event.

Create stack
```bash
aws cloudformation create-stack --stack-name gamer --template-body file://gamer.yaml --region eu-west-1 --capabilities CAPABILITY_NAMED_IAM --parameters file://myparameters.json
```

Get coffee image build takes about an hour.

When stack is complete you have built a new AMI and your stack is ready to deploy.

Scale your Autoscaling Group to 1.

When your instance is running you can connect your Nice DCV client.

```
<Instance IP>:8443#gamer
```

I cannot help with networking issues due to your home setup.

## Deleting

Delete the stack and then clean up any snapshots and AMIs you may have laying around.


## Roadmap

- Lambda to clean up old snapshots based on n snapshots to retain.
- SMS to warn of spot termination
- Automatic scale in when Nice DCV session has been idle for n minutes
- Tagging
- Billing alerts
- Other image recipes
