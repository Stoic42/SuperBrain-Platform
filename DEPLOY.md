# 部署说明

## 部署到 superbrain.ton-ton.fun

### 前置要求

1. **SSH密钥配置**：确保已配置SSH密钥认证，无需密码即可登录服务器
2. **服务器访问权限**：确保有权限访问 `82.157.123.207` 服务器
3. **Nginx配置**：确保服务器已安装Nginx，并配置了域名 `superbrain.ton-ton.fun`

### Windows系统部署

```powershell
# 在 platform 目录下运行
cd platform
.\deploy.ps1
```

### Linux/Mac系统部署

```bash
# 在 platform 目录下运行
cd platform
chmod +x deploy.sh
./deploy.sh
```

### 手动部署步骤

如果自动部署脚本无法运行，可以手动执行以下步骤：

#### 1. 连接到服务器

```bash
ssh root@82.157.123.207
```

#### 2. 创建目录结构

```bash
mkdir -p /var/www/superbrain/data
mkdir -p /var/www/superbrain/content
```

#### 3. 上传文件

从本地执行：

```bash
# 上传主HTML文件
scp 超脑黑客松综合管理平台.html root@82.157.123.207:/var/www/superbrain/index.html

# 上传数据文件
scp -r data/* root@82.157.123.207:/var/www/superbrain/data/

# 上传文档文件（如果存在）
scp -r content/* root@82.157.123.207:/var/www/superbrain/content/
```

#### 4. 设置文件权限

在服务器上执行：

```bash
chmod -R 755 /var/www/superbrain
chmod 644 /var/www/superbrain/index.html
chmod 644 /var/www/superbrain/data/*.json
```

#### 5. 配置Nginx

创建 `/etc/nginx/sites-available/superbrain.ton-ton.fun`：

```nginx
server {
    listen 80;
    server_name superbrain.ton-ton.fun;
    
    root /var/www/superbrain;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # 支持JSON文件
    location ~* \.(json)$ {
        add_header Content-Type application/json;
        charset utf-8;
    }
    
    # 支持Markdown文件
    location ~* \.(md)$ {
        add_header Content-Type text/markdown;
        charset utf-8;
    }
    
    # 支持CORS（如果需要）
    add_header Access-Control-Allow-Origin *;
}
```

启用配置：

```bash
sudo ln -s /etc/nginx/sites-available/superbrain.ton-ton.fun /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 验证部署

1. 访问 `http://superbrain.ton-ton.fun` 查看主页
2. 检查浏览器控制台是否有错误
3. 测试文档查看器功能

### 注意事项

1. **不影响 shenest.ton-ton.fun**：确保Nginx配置中使用了不同的 `server_name`，不会相互影响
2. **文件路径**：文档链接使用的是相对路径，确保部署后目录结构保持一致
3. **CORS问题**：如果遇到跨域问题，可能需要配置CORS头（已在Nginx配置中包含）
4. **HTTPS**：生产环境建议配置HTTPS证书（Let's Encrypt）

### 故障排查

#### 文件404错误
- 检查文件路径是否正确
- 检查文件权限（应该是644）
- 检查Nginx配置中的 `root` 路径

#### 文档加载失败
- 检查Markdown文件是否已上传
- 检查文件路径（相对路径）
- 检查浏览器控制台的错误信息

#### CSS/JS加载失败
- 检查CDN链接是否可访问
- 检查网络连接

### 更新部署

更新时只需重新运行部署脚本，或手动上传更新的文件即可。建议在部署前备份旧版本。

#### Windows系统
```powershell
cd platform
.\deploy.ps1
```

#### Linux/Mac系统
```bash
cd platform
chmod +x deploy.sh
./deploy.sh
```

### 本地开发环境

如果在本地开发时遇到CORS错误（`file://`协议限制），请使用本地HTTP服务器：

#### 使用Python（推荐）
```bash
cd platform
python -m http.server 8000
# 然后访问 http://localhost:8000
```

#### 使用Node.js
```bash
cd platform
npx http-server -p 8000
# 然后访问 http://localhost:8000
```

#### 使用PHP
```bash
cd platform
php -S localhost:8000
# 然后访问 http://localhost:8000
```

这样可以避免浏览器的CORS限制，正常加载JSON数据文件。

