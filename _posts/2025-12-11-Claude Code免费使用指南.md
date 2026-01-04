---
title: "Claude Code白嫖指南"
layout: post
date: 2025-12-11
tags: [claude]
category: [薅羊毛]
author: XieChen
toc:  true
---

## 一、claude code安装与配置

### 1、下载claude code

打开github https://github.com/anthropics/claude-code 下载claude code（nodejs安装方式，需要提前安装 [Node.js 18+](https://nodejs.org/en/download/))

```powershell
npm install -g @anthropic-ai/claude-code
```

### 2、配置claude code环境

在C:\Users\Administrator\.claude目录下新建文件settings.json

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "123",
    "ANTHROPIC_BASE_URL": "http://localhost:3457",
    "ANTHROPIC_MODEL": "claude-opus-4-5-20251101",
    "MAX_THINKING_TOKENS": "31999"
  }
}
```

## 二、注册zai.is账号

### 1、使用discard注册登录zai.is账号

地址： https://zai.is/auth?redirect=%2Fapi

### 2、登录zai.is

返回 https://zai.is/  页面登录，打开f12控制台，找到本地存放的token
![image-20251211104500132](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20251211104500132.png)

## 三、配置代理代理服务并启动

### 1、配置代理脚本token

脚本代码如下，自行保存为claude-code-proxy.js文件使用

```javascript
/**
 * Claude Code 代理服务器
 * 
 * 将 Anthropic 格式请求转换为 OpenAI 格式，转发到目标 API
 * 
 * 使用方法：
 * 1. 启动代理: node claude-code-proxy.js
 * 2. 设置环境变量后启动 Claude Code:
 *    Windows CMD:
 *      set ANTHROPIC_BASE_URL=http://localhost:3457
 *      claude
 *    PowerShell:
 *      $env:ANTHROPIC_BASE_URL="http://localhost:3457"
 *      claude
 *    Linux/Mac:
 *      ANTHROPIC_BASE_URL=http://localhost:3457 claude
 */

const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
app.use(cors());
app.use(express.json({ limit: '50mb' }));

// 目标 API 配置（OpenAI 格式）
const TARGET_API = {
  baseUrl: 'https://zai.is/api/v1',
  apiKey: '这里填登录zai.is后存储在本地的token,过期了就重新登录获取token'
};

// 缓存的模型列表
let cachedModels = [];

// 获取模型列表
async function fetchModels() {
  try {
    const response = await axios.get(`${TARGET_API.baseUrl}/models`, {
      headers: {
        'Authorization': `Bearer ${TARGET_API.apiKey}`
      },
      timeout: 30000
    });
    cachedModels = response.data.data || response.data || [];
    console.log(`✅ 获取到 ${cachedModels.length} 个模型`);
    return cachedModels;
  } catch (error) {
    console.error('获取模型列表失败:', error.message);
    return cachedModels;
  }
}

// 启动时获取模型
fetchModels();

// 请求日志
function logRequest(method, path, status, duration) {
  const timestamp = new Date().toLocaleTimeString();
  const statusIcon = status < 400 ? '✅' : '❌';
  console.log(`${statusIcon} [${timestamp}] ${method} ${path} - ${status} (${duration}ms)`);
}

// Anthropic 模型列表端点
app.get('/v1/models', async (req, res) => {
  const models = cachedModels.length > 0 ? cachedModels : await fetchModels();
  res.json({
    object: 'list',
    data: models.map(m => ({
      id: m.id || m,
      object: 'model',
      created: Date.now(),
      owned_by: 'anthropic'
    }))
  });
});

// Anthropic Messages API 端点（核心）
app.post('/v1/messages', async (req, res) => {
  const startTime = Date.now();
  
  try {
    const { model, messages, max_tokens, stream, system, temperature, top_p, stop_sequences } = req.body;
    
    console.log(`\n🤖 收到 Anthropic 请求: model=${model}, stream=${stream}`);
    
    // 构建 OpenAI 格式的消息
    const openaiMessages = [];
    
    // 处理 system prompt
    if (system) {
      let systemContent = '';
      if (typeof system === 'string') {
        systemContent = system;
      } else if (Array.isArray(system)) {
        systemContent = system.map(s => {
          if (typeof s === 'string') return s;
          if (s.type === 'text') return s.text;
          return JSON.stringify(s);
        }).join('\n');
      }
      if (systemContent) {
        openaiMessages.push({ role: 'system', content: systemContent });
      }
    }
    
    // 转换 Anthropic 消息格式到 OpenAI 格式
    if (messages && Array.isArray(messages)) {
      for (const msg of messages) {
        const openaiMsg = { role: msg.role };
        
        // 处理 content
        if (typeof msg.content === 'string') {
          openaiMsg.content = msg.content;
        } else if (Array.isArray(msg.content)) {
          // 复杂内容（可能包含图片等）
          const parts = [];
          for (const block of msg.content) {
            if (block.type === 'text') {
              parts.push({ type: 'text', text: block.text });
            } else if (block.type === 'image') {
              // Anthropic 图片格式转 OpenAI
              const imageData = block.source?.data || '';
              const mediaType = block.source?.media_type || 'image/png';
              parts.push({
                type: 'image_url',
                image_url: {
                  url: imageData.startsWith('data:') ? imageData : `data:${mediaType};base64,${imageData}`
                }
              });
            } else if (block.type === 'tool_use') {
              // 工具调用
              parts.push({ type: 'text', text: `[Tool: ${block.name}] ${JSON.stringify(block.input)}` });
            } else if (block.type === 'tool_result') {
              // 工具结果
              parts.push({ type: 'text', text: block.content || '' });
            }
          }
          
          // 如果只有文本，简化为字符串
          if (parts.length === 1 && parts[0].type === 'text') {
            openaiMsg.content = parts[0].text;
          } else if (parts.every(p => p.type === 'text')) {
            openaiMsg.content = parts.map(p => p.text).join('\n');
          } else {
            openaiMsg.content = parts;
          }
        }
        
        openaiMessages.push(openaiMsg);
      }
    }
    
    // 构建 OpenAI 请求
    const openaiRequest = {
      model: model,
      messages: openaiMessages,
      max_tokens: max_tokens || 4096,
      stream: stream || false
    };
    
    if (temperature !== undefined) openaiRequest.temperature = temperature;
    if (top_p !== undefined) openaiRequest.top_p = top_p;
    if (stop_sequences) openaiRequest.stop = stop_sequences;
    
    console.log(`📡 转发到 OpenAI 格式: ${TARGET_API.baseUrl}/chat/completions`);
    
    if (stream) {
      // 流式响应
      await handleStreamResponse(req, res, openaiRequest, model, startTime);
    } else {
      // 非流式响应
      await handleNonStreamResponse(req, res, openaiRequest, model, startTime);
    }
    
  } catch (error) {
    const duration = Date.now() - startTime;
    console.error('❌ 代理错误:', error.message);
    logRequest('POST', '/v1/messages', error.response?.status || 500, duration);
    
    res.status(error.response?.status || 500).json({
      type: 'error',
      error: {
        type: 'api_error',
        message: error.response?.data?.error?.message || error.message
      }
    });
  }
});

// 处理流式响应
async function handleStreamResponse(req, res, openaiRequest, model, startTime) {
  const response = await axios.post(`${TARGET_API.baseUrl}/chat/completions`, openaiRequest, {
    headers: {
      'Authorization': `Bearer ${TARGET_API.apiKey}`,
      'Content-Type': 'application/json'
    },
    responseType: 'stream',
    timeout: 300000
  });
  
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  
  const messageId = `msg_${Date.now()}`;
  let inputTokens = 0;
  let outputTokens = 0;
  
  // 发送 message_start 事件
  const messageStart = {
    type: 'message_start',
    message: {
      id: messageId,
      type: 'message',
      role: 'assistant',
      content: [],
      model: model,
      stop_reason: null,
      stop_sequence: null,
      usage: { input_tokens: inputTokens, output_tokens: outputTokens }
    }
  };
  res.write(`event: message_start\ndata: ${JSON.stringify(messageStart)}\n\n`);
  
  // 发送 content_block_start 事件
  const blockStart = {
    type: 'content_block_start',
    index: 0,
    content_block: { type: 'text', text: '' }
  };
  res.write(`event: content_block_start\ndata: ${JSON.stringify(blockStart)}\n\n`);
  
  let buffer = '';
  
  response.data.on('data', (chunk) => {
    buffer += chunk.toString();
    const lines = buffer.split('\n');
    buffer = lines.pop() || '';
    
    for (const line of lines) {
      if (line.startsWith('data: ')) {
        const data = line.slice(6).trim();
        if (data === '[DONE]') continue;
        
        try {
          const parsed = JSON.parse(data);
          const delta = parsed.choices?.[0]?.delta?.content || '';
          
          if (delta) {
            outputTokens++;
            // 发送 content_block_delta 事件
            const deltaEvent = {
              type: 'content_block_delta',
              index: 0,
              delta: { type: 'text_delta', text: delta }
            };
            res.write(`event: content_block_delta\ndata: ${JSON.stringify(deltaEvent)}\n\n`);
          }
          
          // 检查是否结束
          if (parsed.choices?.[0]?.finish_reason) {
            // 发送 content_block_stop
            res.write(`event: content_block_stop\ndata: ${JSON.stringify({ type: 'content_block_stop', index: 0 })}\n\n`);
            
            // 发送 message_delta
            const messageDelta = {
              type: 'message_delta',
              delta: { stop_reason: 'end_turn', stop_sequence: null },
              usage: { output_tokens: outputTokens }
            };
            res.write(`event: message_delta\ndata: ${JSON.stringify(messageDelta)}\n\n`);
            
            // 发送 message_stop
            res.write(`event: message_stop\ndata: ${JSON.stringify({ type: 'message_stop' })}\n\n`);
          }
        } catch (e) {
          // 忽略解析错误
        }
      }
    }
  });
  
  response.data.on('end', () => {
    const duration = Date.now() - startTime;
    logRequest('POST', '/v1/messages (stream)', 200, duration);
    res.end();
  });
  
  response.data.on('error', (err) => {
    console.error('流错误:', err.message);
    res.end();
  });
}

// 处理非流式响应
async function handleNonStreamResponse(req, res, openaiRequest, model, startTime) {
  const response = await axios.post(`${TARGET_API.baseUrl}/chat/completions`, openaiRequest, {
    headers: {
      'Authorization': `Bearer ${TARGET_API.apiKey}`,
      'Content-Type': 'application/json'
    },
    timeout: 300000
  });
  
  const data = response.data;
  const content = data.choices?.[0]?.message?.content || '';
  const finishReason = data.choices?.[0]?.finish_reason;
  
  // 转换为 Anthropic 响应格式
  const anthropicResponse = {
    id: data.id || `msg_${Date.now()}`,
    type: 'message',
    role: 'assistant',
    content: [{ type: 'text', text: content }],
    model: model,
    stop_reason: finishReason === 'stop' ? 'end_turn' : (finishReason === 'length' ? 'max_tokens' : 'end_turn'),
    stop_sequence: null,
    usage: {
      input_tokens: data.usage?.prompt_tokens || 0,
      output_tokens: data.usage?.completion_tokens || 0
    }
  };
  
  const duration = Date.now() - startTime;
  logRequest('POST', '/v1/messages', 200, duration);
  
  res.json(anthropicResponse);
}

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'ok', proxy: 'claude-code-proxy' });
});

// 根路径
app.get('/', (req, res) => {
  res.json({
    name: 'Claude Code Proxy',
    description: 'OpenAI -> Anthropic 格式转换代理',
    target: TARGET_API.baseUrl,
    models: cachedModels.map(m => m.id || m).slice(0, 10),
    usage: 'ANTHROPIC_BASE_URL=http://localhost:3457 claude'
  });
});

const PORT = 3457;

app.listen(PORT, () => {
  console.log('');
  console.log('╔══════════════════════════════════════════════════════════════╗');
  console.log('║         🤖 Claude Code 代理服务器已启动                       ║');
  console.log('╠══════════════════════════════════════════════════════════════╣');
  console.log(`║  代理地址: http://localhost:${PORT}                            ║`);
  console.log(`║  目标 API: ${TARGET_API.baseUrl.padEnd(43)}║`);
  console.log('╠══════════════════════════════════════════════════════════════╣');
  console.log('║  使用方法:                                                    ║');
  console.log('║                                                              ║');
  console.log('║  Windows CMD:                                                ║');
  console.log(`║    set ANTHROPIC_BASE_URL=http://localhost:${PORT}             ║`);
  console.log('║    claude                                                    ║');
  console.log('║                                                              ║');
  console.log('║  PowerShell:                                                 ║');
  console.log(`║    $env:ANTHROPIC_BASE_URL="http://localhost:${PORT}"          ║`);
  console.log('║    claude                                                    ║');
  console.log('║                                                              ║');
  console.log('║  Linux/Mac:                                                  ║');
  console.log(`║    ANTHROPIC_BASE_URL=http://localhost:${PORT} claude          ║`);
  console.log('╚══════════════════════════════════════════════════════════════╝');
  console.log('');
});

```

### 2、启动代理服务

```
npm install express
npm install cors
npm instal axios
node 实际目录\claude-code-proxy.js
```

代理服务启动成功效果如下
![image-20251211101548341](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20251211101548341.png)

## 四、启动claude code

### 1、打开一个新的控制台启动claude code

```
claude
```

![image-20251211105848733](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20251211105848733.png)
