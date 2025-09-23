<?php

declare(strict_types=1);

require_once __DIR__ . '/../vendor/autoload.php';

use App\HelloWorld;

// Error handling for development
error_reporting(E_ALL);
ini_set('display_errors', '1');

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My awesome PHP Application</title>
    <style>
        body { font-family: sans-serif; margin: 0; line-height: 1.6; }
        .container { max-width: min(70vw, 800px); min-height: 100vh; margin: 0 auto; display: flex; flex-direction: column; gap: 2.4rem; }
        .header { text-align: center; }
        .header h1 { font-size: min(4vw, 2.6rem); margin-bottom: 0; }
        .subtitle { font-size: min(2.5vw, 1.6rem); color: #6c757d; font-style: italic; margin-top: 0; }
        .info { background: #e7f3ff; padding: 12px 32px; border-radius: 4px; border-left: 4px solid #007bff; font-size: min(2vw, 1.4rem); }
        .footer { text-align: center; color: #6c757d; font-size: min(1.6vw, 1.2rem); }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 My awesome PHP Application</h1>
            <p class="subtitle">A clean, quality-focused, PHP project foundation</p>
        </div>
        
        <div class="info">
            <p><strong><?php echo new HelloWorld()->helloWorld() ?></strong></p>
            <p>This project includes:</p>
            <ul>
                <li>Automated testing</li>
                <li>Code coverage</li>
                <li>Mutation testing</li>
                <li>Code quality tools (PHPStan, Psalm, etc.)</li>
                <li>Docker support (+ docker-compose)</li>
                <li>CI/CD pipeline with GitHub Actions</li>
            </ul>
        </div>

        <footer class="footer">
            <p>Built with ❤️ using <a href="https://github.com/IngeniozIT/php-skeleton"><code>ingenioz-it/php-skeleton</code></a></p>
        </footer>
    </div>
</body>
</html>
