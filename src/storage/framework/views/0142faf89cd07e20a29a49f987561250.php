<!DOCTYPE html>
<html lang="<?php echo e(str_replace('_', '-', app()->getLocale())); ?>">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Laravel Enterprise Platform</title>
        <style>
            body {
                font-family: 'Nunito', sans-serif;
                margin: 0;
                padding: 0;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
                color: white;
            }
            .container {
                text-align: center;
                max-width: 600px;
                padding: 40px;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 20px;
                backdrop-filter: blur(10px);
                box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
            }
            h1 {
                font-size: 3rem;
                margin-bottom: 1rem;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
            }
            p {
                font-size: 1.2rem;
                margin-bottom: 2rem;
                opacity: 0.9;
            }
            .status {
                display: inline-block;
                padding: 10px 20px;
                background: rgba(255, 255, 255, 0.2);
                border-radius: 10px;
                font-weight: bold;
            }
            .links {
                margin-top: 2rem;
            }
            .links a {
                color: white;
                text-decoration: none;
                margin: 0 15px;
                padding: 10px 20px;
                border: 2px solid rgba(255, 255, 255, 0.3);
                border-radius: 25px;
                transition: all 0.3s ease;
            }
            .links a:hover {
                background: rgba(255, 255, 255, 0.2);
                transform: translateY(-2px);
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 Laravel Enterprise Platform</h1>
            <p>Professional Laravel Docker Development Environment</p>
            <div class="status">
                ✅ Application Running Successfully
            </div>
            <div class="links">
                <a href="/health">Health Check</a>
                <a href="/api/status">API Status</a>
            </div>
            <p style="margin-top: 2rem; font-size: 0.9rem; opacity: 0.7;">
                Laravel <?php echo e(app()->version()); ?> | PHP <?php echo e(PHP_VERSION); ?>

            </p>
        </div>
    </body>
</html><?php /**PATH /home/laila_ibrahim/projects/Docker-laravel-project/src/resources/views/welcome.blade.php ENDPATH**/ ?>