<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Laravel Docker</title>
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,600&display=swap" rel="stylesheet" />
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Figtree', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        
        .container {
            text-align: center;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            max-width: 600px;
            width: 90%;
        }
        
        .logo {
            width: 80px;
            height: 80px;
            margin: 0 auto 2rem;
            background: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            color: #667eea;
            font-weight: 600;
        }
        
        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
            font-weight: 600;
        }
        
        .subtitle {
            font-size: 1.2rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
            margin: 2rem 0;
        }
        
        .feature {
            background: rgba(255, 255, 255, 0.1);
            padding: 1.5rem;
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .feature h3 {
            font-size: 1.1rem;
            margin-bottom: 0.5rem;
            color: #fff;
        }
        
        .feature p {
            font-size: 0.9rem;
            opacity: 0.8;
            line-height: 1.5;
        }
        
        .status {
            margin-top: 2rem;
            padding: 1rem;
            background: rgba(34, 197, 94, 0.2);
            border: 1px solid rgba(34, 197, 94, 0.3);
            border-radius: 10px;
            color: #dcfce7;
        }
        
        .links {
            margin-top: 2rem;
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .link {
            display: inline-block;
            padding: 0.75rem 1.5rem;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            text-decoration: none;
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            transition: all 0.3s ease;
            font-weight: 500;
        }
        
        .link:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }
        
        .version-info {
            margin-top: 2rem;
            font-size: 0.9rem;
            opacity: 0.7;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">L</div>
        <h1>Laravel Docker</h1>
        <p class="subtitle">Professional Laravel Development Environment</p>
        
        <div class="features">
            <div class="feature">
                <h3>🐳 Docker Ready</h3>
                <p>Complete Docker setup with Nginx, MySQL, Redis, and development tools</p>
            </div>
            <div class="feature">
                <h3>⚡ Modern Stack</h3>
                <p>Laravel 10, PHP 8.2, MySQL 8.0, Redis, and Node.js for asset compilation</p>
            </div>
            <div class="feature">
                <h3>🔧 Dev Tools</h3>
                <p>PHPUnit, PHPStan, PHP CS Fixer, Rector, and Xdebug for professional development</p>
            </div>
            <div class="feature">
                <h3>📧 Mail Testing</h3>
                <p>Mailhog integration for easy email testing and debugging</p>
            </div>
        </div>
        
        <div class="status">
            <strong>🎉 Laravel is running successfully!</strong><br>
            Your development environment is ready to use.
        </div>
        
        <div class="links">
            <a href="/health" class="link">Health Check</a>
            <a href="/api/status" class="link">API Status</a>
            <a href="http://localhost:8025" class="link" target="_blank">Mailhog</a>
        </div>
        
        <div class="version-info">
            Laravel {{ app()->version() }} • PHP {{ PHP_VERSION }} • Environment: {{ app()->environment() }}
        </div>
    </div>
</body>
</html>
