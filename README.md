# AI Calendar

A calendar app with AI functionality.

## Getting Started

You will need to create a '.env' file in the project's root directory. Its contents should replicate this:


DB_ADDR=[Host's private IP address]<br />
DB_PORT=[Port of the database]<br />
DB_NAME=[Name of the database]<br />
DB_USER=[Username]<br />
DB_PASS=[Password]<br />



When filling in, remove the brackets.

Note: localhost cannot be used for the 'DB_ADDR' as the emulator will go to its own localhost rather than the host's.

If you get issues with connecting/authenticating with the database, try the solutions on this [stackoverflow page](https://stackoverflow.com/questions/14779104/mysql-how-to-allow-remote-connection-to-mysql).

## IDE
We recommend using Android Studio or VSCode. The following guide is assuming the ide used is VSCode. Clone the project and open it with VSCode.

## Install Dependencies
Run "flutter pub get" to install dependencies. 

## Create Android Device
Create an android device with android studio AVD, ideally models that are at least Android Pixel 7 with api 34. 

## Run
Run main.dart with "run without debugging".

## Example Database Connection 
This is the database process we used for our project. First download docker: https://www.docker.com/products/docker-desktop/

Next download the compose.yaml file from our project directory into a separate folder called "mariadb".

Open compose.yaml in an editor and fill in a password for your database.

"cd" into mariadb via terminal and run "docker compose up". 

Afterwards, access adminer with http://127.0.0.1:8080/.

Import our sample database data provided in the project directory called "ai-calendar-db-data.sql.gz".

Now that the database is populated, the .env file to connect to this db should look like:

DB_ADDR=[insert you ipv4 address]
DB_PORT=9090
DB_NAME=ai-calendar-db
DB_USER=admin
DB_PASS=[password detailed in your compose.yaml file]

## Code References
https://www.youtube.com/watch?v=ASCs_g8RJ9s
https://www.geeksforgeeks.org/flutter-create-interactive-event-calendars/
https://www.dhiwise.com/post/get-organized-with-flutter-calendar-essentials-a-comprehensive-tutorial
https://medium.com/mobiledev/guide-crafting-calendar-app-flutter-b91d730902af
https://stackoverflow.com/questions/51910079/adding-an-event-to-a-calendar-from-flutter-app


