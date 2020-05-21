<?php
$servername = "mysql";
$username = "root";
$password = "";

$CONNECT_RETRY_LIMIT = 10;
$SLEEP_TIME = 5;

/**
 * Connect to the mysql database; retry `CONNECT_RETRY_LIMIT`
 * times in case it's starting but not yet available
 */
for ($x = 0; $x <= $CONNECT_RETRY_LIMIT; $x++) {
    $conn = new mysqli($servername, $username, $password);
    if (!$conn->connect_error) {
        echo "Connected successfully\n";
        exit(0);
    }
    sleep($SLEEP_TIME);
}

fwrite(STDERR, "Connection failed: " . $conn->connect_error . "\n");
exit(1);

?>
