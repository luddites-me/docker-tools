<?php
$servername = "mysql";
$username = "root";
$password = "";

$conn = new mysqli($servername, $username, $password);

if ($conn->connect_error) {
    fwrite(STDERR, "Connection failed: " . $conn->connect_error);
    exit(1);
}

if (!$conn->query("CREATE DATABASE magento2") ||
    !$conn->query("CREATE USER 'magento_db_user'@'%' IDENTIFIED BY 'magento_db_password'") ||
    !$conn->query("GRANT ALL PRIVILEGES ON magento2.* TO 'magento_db_user'@'%'") ||
    !$conn->query("FLUSH PRIVILEGES")) {
        fwrite(STDERR, "creation failed: (" . $conn->errno . ") " . $conn->error);
        exit(1);
}

?>
