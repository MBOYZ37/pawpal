<!DOCTYPE html>
<html>
<head>
    <title>Payment Success</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        .success { color: green; font-size: 24px; font-weight: bold; }
        p { font-size: 18px; }
    </style>
</head>
<body>
    <h1 class="success">Payment Successful!</h1>
    <p>Thank you for your donation.</p>
    <p>You can now close this browser tab and return to the app.</p>
    
    <script>
        // Optional: Close window automatically after 3 seconds
        setTimeout(function(){ window.close(); }, 5000);
    </script>
</body>
</html>