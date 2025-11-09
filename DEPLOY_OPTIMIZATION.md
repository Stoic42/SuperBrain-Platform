# 部署优化说明

## 📋 资源控制措施

### 1. 文件传输优化
- ✅ 使用rsync增量同步（如果可用），只传输变更的文件
- ✅ 避免重复上传未变更的文件
- ✅ 压缩传输（rsync的-z选项）

### 2. 服务器负载控制

#### 前端优化
- **防抖处理**：风险矩阵切换时使用防抖，避免频繁加载
- **缓存机制**：风险数据加载后缓存，避免重复请求
- **按需加载**：只在切换到对应标签时才加载数据
- **错误处理**：添加完善的错误处理和重试机制

#### 部署优化
- **增量上传**：使用rsync只同步变更文件
- **文件压缩**：HTML文件已压缩（生产环境建议进一步压缩）
- **静态资源**：使用CDN加载外部库（marked.js, highlight.js等）

### 3. 性能监控建议

```bash
# 服务器监控命令
# CPU使用率
top -bn1 | grep "Cpu(s)" | awk '{print $2}'

# 内存使用
free -h

# 磁盘使用
df -h

# Nginx状态（如果配置了stub_status）
curl http://localhost/nginx_status
```

### 4. 资源限制配置

#### Nginx配置建议
```nginx
# 限制请求大小
client_max_body_size 10M;

# 限制并发连接
worker_connections 1024;

# 启用gzip压缩
gzip on;
gzip_types text/html text/css application/javascript application/json text/plain;
gzip_min_length 1000;

# 静态文件缓存
location ~* \.(jpg|jpeg|png|gif|ico|css|js|json)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

#### 服务器资源监控脚本
```bash
#!/bin/bash
# monitor.sh - 简单的资源监控脚本

echo "=== 服务器资源使用情况 ==="
echo "CPU使用率:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}'
echo ""
echo "内存使用:"
free -h
echo ""
echo "磁盘使用:"
df -h /var/www/superbrain
echo ""
echo "Nginx进程数:"
ps aux | grep nginx | grep -v grep | wc -l
```

## 🚀 部署最佳实践

1. **避免高峰时段部署**：选择访问量低的时间段
2. **灰度发布**：先部署到测试环境验证
3. **备份策略**：部署前备份当前版本
4. **监控部署后状态**：部署后检查服务器资源使用

## 📊 当前优化状态

- ✅ 增量文件同步（rsync）
- ✅ 前端数据缓存
- ✅ 防抖和节流处理
- ✅ 按需加载数据
- ✅ 错误处理和重试机制
- ⚠️ 建议：配置Nginx缓存策略
- ⚠️ 建议：启用gzip压缩
- ⚠️ 建议：设置资源监控告警

## 🔍 故障排查

如果发现服务器负载过高：

1. 检查Nginx日志：`tail -f /var/log/nginx/access.log`
2. 检查错误日志：`tail -f /var/log/nginx/error.log`
3. 检查进程：`ps aux | grep nginx`
4. 检查连接数：`netstat -an | grep :80 | wc -l`

