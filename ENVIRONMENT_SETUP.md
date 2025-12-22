# 🔧 Environment Setup Guide

## 📋 **Overview**

This guide explains how to set up environment variables and configuration for your ABA data collection app, including the note drafting service.

## 🎯 **Current Configuration System**

Your app uses **environment variables** loaded from a `.env` file. This is the secure way to handle credentials and configuration.

### **Existing Configuration Files:**
- `lib/config/app_config.dart` - Main app configuration (loads from .env)
- `lib/config/note_drafting_config.dart` - Note drafting service configuration (loads from .env)
- `.env.example` - Template for environment variables (copy to `.env` and fill in your values)
- `lib/config/app_config.dart.template` - Template for app configuration

## 🔧 **Setting Up Environment Variables**

### **Step 1: Create `.env` File**

1. Copy the example file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and fill in your actual credentials:
   ```env
   # FileMaker API Configuration
   FM_BASE_URL=https://fms.sphereemr.com/fmi/data/vLatest
   FM_DATABASE=EIDBI
   FM_USERNAME=your_filemaker_username
   FM_PASSWORD=your_filemaker_password

   # MCP API Configuration
   MCP_BASE_URL=https://portal.sphereemr.com/api

   # Note Drafting API Configuration
   NOTE_DRAFTING_API_KEY=your_note_drafting_api_key
   OPENAI_API_KEY=your_openai_api_key
   ```

### **Step 2: Configuration Files**

The app automatically loads these values from `.env`:

**Main App Configuration (`lib/config/app_config.dart`):**
```dart
class AppConfig {
  // FileMaker Configuration (loaded from .env)
  static String get baseUrl => dotenv.env['FM_BASE_URL'] ?? 'https://fms.sphereemr.com/fmi/data/vLatest';
  static String get database => dotenv.env['FM_DATABASE'] ?? 'EIDBI';
  static String? get username => dotenv.env['FM_USERNAME'];
  static String? get password => dotenv.env['FM_PASSWORD'];
  
  // App Configuration
  static const String appName = 'Attendance';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
}
```

**Note Drafting Configuration (`lib/config/note_drafting_config.dart`):**
```dart
class NoteDraftingConfig {
  // API Configuration
  static const String apiUrl = 'https://arawello.ai/v1/chat/completions';
  static const String model = 'meta-llama/Meta-Llama-3.1-8B-Instruct';
  static const double temperature = 0.3;
  static const int maxTokens = 500;
  
  // API Keys (loaded from .env file)
  static String? get apiKey => dotenv.env['NOTE_DRAFTING_API_KEY'];
  static String? get openaiApiKey => dotenv.env['OPENAI_API_KEY'];
}
```

**⚠️ Important:** Never commit your `.env` file to version control! It's already in `.gitignore`.

## 🔑 **Setting Up API Keys**

### **Recommended: Use Environment Variables**
1. Open your `.env` file
2. Set your API keys:
   ```env
   NOTE_DRAFTING_API_KEY=your-actual-api-key-here
   OPENAI_API_KEY=sk-your-openai-key-here
   ```
3. Save the file and restart the app

### **Alternative: Pass API Key at Runtime**
```dart
final noteDraft = await NoteDraftingService.generateNoteDraft(
  session: session,
  ragContext: ragContext,
  apiKey: "your-api-key-here", // Pass API key directly
);
```

## 🧪 **Testing Your Configuration**

### **Run Configuration Test**
```bash
dart test_configuration.dart
```

This will:
- ✅ Check your current configuration
- ✅ Verify API key setup
- ✅ Test message building (no API key required)
- ✅ Test API calls (if API key is configured)
- ✅ Provide configuration recommendations

### **Expected Output**
```
🔧 Testing Configuration Setup
==============================

📋 Test 1: Configuration Check
-------------------------------
✅ Configuration loaded:
   - API URL: https://arawello.ai/v1/chat/completions
   - Model: gpt-4
   - Temperature: 0.3
   - Max Tokens: 500
   - Has API Key: false
   - API Key Source: none

🔑 Test 2: API Key Configuration
--------------------------------
⚠️  No API key configured
   - To configure: Add NOTE_DRAFTING_API_KEY or OPENAI_API_KEY to your .env file

📝 Test 3: Message Building Test
--------------------------------
✅ Messages built successfully!
   - System message length: 200 characters
   - User message length: 300 characters

🌐 Test 4: API Call Test
------------------------
⚠️  No API key configured, skipping API call test
   - To test API calls:
     1. Add NOTE_DRAFTING_API_KEY or OPENAI_API_KEY to your .env file
     2. Restart the app
     3. Run this test again

💡 Test 5: Configuration Recommendations
---------------------------------------
📋 Current setup:
   - Configuration file: lib/config/note_drafting_config.dart
   - API URL: https://arawello.ai/v1/chat/completions
   - Model: gpt-4
   - Temperature: 0.3
   - Max Tokens: 500

🔧 To configure API key:
   1. Open your .env file
   2. Add NOTE_DRAFTING_API_KEY=your-api-key-here
   3. Or add OPENAI_API_KEY=your-openai-key-here
   4. Save the file and restart the app
   5. Run this test again

🌐 Supported APIs:
   - arawello.ai (default)
   - OpenAI API (if openaiApiKey is set)
   - Any OpenAI-compatible API

🎉 Configuration test completed!
💡 The note drafting service is ready to use.
```

## 🚀 **Quick Start**

### **1. Test Current Setup**
```bash
dart test_configuration.dart
```

### **2. Configure API Key (if needed)**
Edit your `.env` file:
```env
NOTE_DRAFTING_API_KEY=your-api-key-here
```

### **3. Test Note Drafting**
```bash
dart test_note_drafting.dart
```

### **4. Run Examples**
```bash
dart example_note_drafting.dart
```

## 🔧 **Advanced Configuration**

### **Using Different APIs**

**OpenAI API:**
Add to your `.env` file:
```env
OPENAI_API_KEY=sk-your-openai-key-here
```

**Custom API:**
You can modify `lib/config/note_drafting_config.dart` to use a different API URL, but API keys should still come from `.env`:
```dart
static const String apiUrl = "https://your-custom-api.com/v1/chat/completions";
// API key still loaded from .env: NOTE_DRAFTING_API_KEY
```

## 📊 **Configuration Summary**

| Setting | Environment Variable | Purpose |
|---------|---------------------|---------|
| FileMaker URL | `FM_BASE_URL` | Database connection |
| FileMaker Database | `FM_DATABASE` | Database name |
| FileMaker Username | `FM_USERNAME` | Database authentication |
| FileMaker Password | `FM_PASSWORD` | Database authentication |
| MCP API URL | `MCP_BASE_URL` | MCP API endpoint |
| Note Drafting API Key | `NOTE_DRAFTING_API_KEY` | AI note generation |
| OpenAI API Key | `OPENAI_API_KEY` | Alternative AI API |

## 🔍 **Troubleshooting**

### **Common Issues**

1. **"API key not configured" error**
   - Check your `.env` file exists
   - Add `NOTE_DRAFTING_API_KEY` or `OPENAI_API_KEY` to your `.env` file
   - Make sure the app restarted after adding the key

2. **"API request failed" error**
   - Check your API key is valid
   - Verify the API endpoint is accessible
   - Check your internet connection

3. **"Configuration file not found" error**
   - Make sure you're in the right directory
   - Check that `lib/config/` directory exists

### **Debug Steps**

1. **Check configuration:**
   ```bash
   dart test_configuration.dart
   ```

2. **Verify file structure:**
   ```bash
   ls -la lib/config/
   ```

3. **Check API key:**
   ```dart
   print('API Key: ${NoteDraftingConfig.getApiKey()}');
   ```
   
4. **Verify .env file is loaded:**
   - Check that `.env` exists in the project root
   - Verify it's listed in `pubspec.yaml` under `assets:`
   - Check app startup logs for "✅ Environment variables loaded from .env"

## 🎉 **Success Metrics**

- ✅ **Configuration loaded** successfully
- ✅ **API key configured** (if needed)
- ✅ **Message building** working
- ✅ **API calls** working (if configured)
- ✅ **Note generation** working

---

**🔧 Your environment is now properly configured for the note drafting service!**
