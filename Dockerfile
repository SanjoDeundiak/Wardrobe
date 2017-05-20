# Use an official Python runtime as a base image
FROM  vapor/vapor:latest

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Build app
RUN ["vapor", "build", "--verbose"]

# Make port 8080 available to the world outside this container
EXPOSE 8080
# Make port 8081 available to the world outside this container
EXPOSE 8081

# Define environment variable
ENV NAME World

# Run app when the container launches
CMD ["vapor", "run", "--env=production"]