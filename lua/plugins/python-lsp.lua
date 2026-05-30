return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- (BasedPyright) التكوين المحسن لـ BasedPyright
        basedpyright = {
          -- (Dynamic Venv Hook) ربط تلقائي لبيئة العمل الافتراضية لضمان عمل OpenCV و YOLO في المشاريع الكبيرة
          on_new_config = function(new_config, new_root_dir)
            local venv_path = new_root_dir .. "/.venv/bin/python"
            if vim.fn.executable(venv_path) == 1 then
              new_config.settings.python = {
                pythonPath = venv_path,
              }
            end
          end,
          settings = {
            basedpyright = {
              analysis = {
                -- (Exclude) استثناء المجلدات الثقيلة لتقليل استهلاك الذاكرة ومنع تعليق LSP
                exclude = {
                  "**/node_modules",
                  "**/__pycache__",
                  "**/.venv",
                  "**/.git",
                  "**/datasets",
                  "**/data",
                  "**/runs", -- مخرجات تدريب YOLO
                },
                -- (Ignore) تجاهل تحليل الملفات في هذه المجلدات (أسرع للأداء)
                ignore = { "**/.venv" },
                -- (Search Paths) البحث التلقائي عن المسارات للمسارات المحلية
                autoSearchPaths = true,
                -- (Library Code Analysis) ضروري لـ OpenCV (cv2) و YOLO (ultralytics)
                useLibraryCodeForTypes = true,
                -- (Indexing) تفعيل الفهرسة العميقة لتسريع البحث في المكتبات الضخمة
                indexing = true,
                -- (Type Checking Mode) وضع فحص الأنواع (basic مناسب للمشاريع العلمية)
                typeCheckingMode = "basic",
                -- (Auto Import) تفعيل الإكمال التلقائي للاستيراد
                autoImportCompletions = true,
                -- (Diagnostic Mode) تحسين الأداء عبر فحص الملفات المفتوحة فقط
                diagnosticMode = "openFilesOnly",
                -- (Inlay Hints) تلميحات الأنواع المضمنة (مفيدة جداً مع OpenCV و YOLO)
                inlayHints = {
                  variableTypes = true,
                  functionReturnTypes = true,
                  callArgumentNames = true,
                },
              },
            },
          },
        },
        -- (Ruff) التكوين لـ Ruff لمعالجة التنسيق والتحقق السريع
        ruff = {
          -- إيقاف التحذيرات التي تتعارض مع BasedPyright
          on_attach = function(client, _)
            if client.name == "ruff" then
              -- تعطيل hover في ruff لصالح basedpyright
              client.server_capabilities.hoverProvider = false
            end
          end,
        },
      },
    },
  },
}
