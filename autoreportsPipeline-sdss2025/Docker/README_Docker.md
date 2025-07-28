

# Docker Instructions

### Create Image
First, add the needed R and LaTex libraries to `requirements.txt` and `latex_requirements.txt`, respectively. After that, change all references to STATE in `container.bat`, `container.sh`, and `Dockerfile` to the state the reports will be generated for. You can then create the image with the following command in Command Line or PowerShell, with STATE matching the name you chose in the other files:

```shell
docker build -f Dockerfile_base -t autoreports:base_STATE .
docker build -t autoreports:STATE .
```

To use this image moving forward, save it as a `.tar` file.

```shell
docker save --output autoreports_STATE.tar autoreports:STATE
```

These `.tar` files can now be stored in an AWS S3 under the bucket `autoreports-docker-images`. Whenever you create a new image or make changes, make sure to update the respective files in the bucket. Reach out to [gchickering@air.org](mailto:gchickering@air.org) for storing your docker file.

The image should only be created this way once IF CHANGES TO THE DOCKERFILE NEED TO BE MADE (SUCH AS ADDING NEW PACKAGES OR DEPENDENCIES) SEE [UPDATE IMAGE](#update-image) SECTION.

### Load Image
If you already have a `.tar` file saved, you can load the included image with terminal command:

```shell
docker load --input autoreports_STATE.tar
```

Once an image is loaded, you will not need to do so again unless the image is changed.

### Run Scripts in Container
Once the set up steps above have been completed, you generally will not need to perform them again. This means that you can freely make changes to the R scripts. To start the container, run the following command in Command Line or PowerShell:

```shell
container.bat
```

If you are using a Mac or Linux-based OS, run this command instead:

```shell
bash ./container.sh
```

Once the container is running, open up a new terminal window. Obtain the container ID through the docker app or the command `docker ps`, and run the following:

```shell
docker exec -it CONTAINER_ID bash
```

You are now free to run commands inside the container as you please. For reference, here is how you could run an R script found in `/AutoReports/Reports`.

```shell
cd AutoReports
Rscript report_shell.R
```

### Stop the Container
To stop the container, you can use the docker app or the terminal.

Using the app, simply go to the running container and click the stop button.
Using the terminal, first exit the bash console, then enter the following command:

```shell
docker stop CONTAINTER_ID
```

It may take a few seconds for the container to stop.

<a name="update-image"></a>
### Update Image
If you are making updates that require new R or LaTex libraries, you can install the libraries while connected to the container through the bash interface.

```shell
Rscript -e 'install.packages("ggplot2")'
```

Try to avoid reinstalling libraries already included in the image, as updates to old libraries may cause compatibility issues. If you need to make some other fundamental change to the current image, such as upgrading the version of R or Ubuntu, you could edit `Dockerfile_base` and `Dockerfile`. In this situation, you will also need to rebuild the Docker image.

```shell
docker build -f Dockerfile_base -t autoreports:base_STATE .
docker build -t autoreports:STATE .
```

For any updates, if this image will be used by others going forward, make sure to save it as a `.tar` file. You can overwrite the existing `autoreports_STATE.tar` file or create a new file. The example command below will overwrite the existing file. Use a different file name if you don't want to do that.

```shell
docker commit CONTAINER_ID autoreports:STATE

docker save --output autoreports_STATE.tar autoreports:STATE
```

If .tar file is created, make sure to update the existing one on AWS S3 Bucket for future use

## Support
For support, email [gchickering@air.org](mailto:gchickering@air.org)
