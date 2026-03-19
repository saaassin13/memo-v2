"use client"

import { useState, useEffect } from "react"
import { cn } from "@/lib/utils"
import {
  Bold,
  Italic,
  List,
  ListOrdered,
  Heading1,
  Heading2,
  Quote,
  Code,
  Link as LinkIcon,
  Image,
  Minus,
  Eye,
  Edit3,
} from "lucide-react"

interface MarkdownEditorProps {
  value: string
  onChange: (value: string) => void
  placeholder?: string
  minRows?: number
  readOnly?: boolean
}

const toolbarItems = [
  { icon: Heading1, label: "标题1", action: (text: string, pos: number) => insertAt(text, pos, "# ", "") },
  { icon: Heading2, label: "标题2", action: (text: string, pos: number) => insertAt(text, pos, "## ", "") },
  { icon: Bold, label: "粗体", action: (text: string, pos: number) => wrapText(text, pos, "**") },
  { icon: Italic, label: "斜体", action: (text: string, pos: number) => wrapText(text, pos, "*") },
  { icon: Quote, label: "引用", action: (text: string, pos: number) => insertAt(text, pos, "> ", "") },
  { icon: Code, label: "代码", action: (text: string, pos: number) => wrapText(text, pos, "`") },
  { icon: List, label: "无序列表", action: (text: string, pos: number) => insertAt(text, pos, "- ", "") },
  { icon: ListOrdered, label: "有序列表", action: (text: string, pos: number) => insertAt(text, pos, "1. ", "") },
  { icon: Minus, label: "分割线", action: (text: string, pos: number) => insertAt(text, pos, "\n---\n", "") },
  { icon: LinkIcon, label: "链接", action: (text: string, pos: number) => insertAt(text, pos, "[链接文字](", ")") },
  { icon: Image, label: "图片", action: (text: string, pos: number) => insertAt(text, pos, "![图片描述](", ")") },
]

function insertAt(text: string, pos: number, before: string, after: string): { text: string; newPos: number } {
  const newText = text.slice(0, pos) + before + after + text.slice(pos)
  return { text: newText, newPos: pos + before.length }
}

function wrapText(text: string, pos: number, wrapper: string): { text: string; newPos: number } {
  const newText = text.slice(0, pos) + wrapper + wrapper + text.slice(pos)
  return { text: newText, newPos: pos + wrapper.length }
}

function renderMarkdown(markdown: string): string {
  let html = markdown
    // 转义HTML
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    // 标题
    .replace(/^### (.+)$/gm, '<h3 class="text-lg font-semibold mt-4 mb-2">$1</h3>')
    .replace(/^## (.+)$/gm, '<h2 class="text-xl font-semibold mt-4 mb-2">$1</h2>')
    .replace(/^# (.+)$/gm, '<h1 class="text-2xl font-bold mt-4 mb-2">$1</h1>')
    // 粗体和斜体
    .replace(/\*\*(.+?)\*\*/g, '<strong class="font-bold">$1</strong>')
    .replace(/\*(.+?)\*/g, '<em class="italic">$1</em>')
    // 行内代码
    .replace(/`([^`]+)`/g, '<code class="bg-muted px-1.5 py-0.5 rounded text-sm font-mono">$1</code>')
    // 引用
    .replace(/^&gt; (.+)$/gm, '<blockquote class="border-l-4 border-primary/30 pl-4 italic text-muted-foreground my-2">$1</blockquote>')
    // 无序列表
    .replace(/^- (.+)$/gm, '<li class="ml-4 list-disc">$1</li>')
    // 有序列表
    .replace(/^\d+\. (.+)$/gm, '<li class="ml-4 list-decimal">$1</li>')
    // 分割线
    .replace(/^---$/gm, '<hr class="my-4 border-border" />')
    // 链接
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" class="text-primary underline" target="_blank" rel="noopener">$1</a>')
    // 图片
    .replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img src="$2" alt="$1" class="max-w-full rounded-lg my-2" />')
    // 换行
    .replace(/\n/g, '<br />')

  return html
}

export function MarkdownEditor({
  value,
  onChange,
  placeholder = "开始输入...",
  minRows = 10,
  readOnly = false,
}: MarkdownEditorProps) {
  // 只读时默认预览模式，编辑时默认编辑模式
  const [mode, setMode] = useState<"edit" | "preview">(readOnly ? "preview" : "edit")

  useEffect(() => {
    setMode(readOnly ? "preview" : "edit")
  }, [readOnly])
  const [textareaRef, setTextareaRef] = useState<HTMLTextAreaElement | null>(null)

  const handleToolbarClick = (action: (text: string, pos: number) => { text: string; newPos: number }) => {
    if (!textareaRef) return
    const pos = textareaRef.selectionStart
    const result = action(value, pos)
    onChange(result.text)
    
    // 延迟设置光标位置
    setTimeout(() => {
      if (textareaRef) {
        textareaRef.focus()
        textareaRef.setSelectionRange(result.newPos, result.newPos)
      }
    }, 0)
  }

  return (
    <div className="rounded-xl border border-border bg-card overflow-hidden">
      {/* 工具栏：只读时隐藏 */}
      <div className={cn("flex items-center justify-between border-b border-border bg-muted/30 px-2 py-1.5", readOnly && "hidden")}>
        <div className="flex items-center gap-0.5 overflow-x-auto">
          {toolbarItems.map((item, index) => {
            const Icon = item.icon
            return (
              <button
                key={index}
                type="button"
                onClick={() => handleToolbarClick(item.action)}
                className="rounded p-1.5 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
                title={item.label}
              >
                <Icon className="h-4 w-4" />
              </button>
            )
          })}
        </div>
        <div className="flex items-center gap-1 ml-2">
          <button
            type="button"
            onClick={() => setMode("edit")}
            className={cn(
              "flex items-center gap-1 rounded px-2 py-1 text-xs font-medium transition-colors",
              mode === "edit"
                ? "bg-primary text-primary-foreground"
                : "text-muted-foreground hover:bg-secondary"
            )}
          >
            <Edit3 className="h-3 w-3" />
            编辑
          </button>
          <button
            type="button"
            onClick={() => setMode("preview")}
            className={cn(
              "flex items-center gap-1 rounded px-2 py-1 text-xs font-medium transition-colors",
              mode === "preview"
                ? "bg-primary text-primary-foreground"
                : "text-muted-foreground hover:bg-secondary"
            )}
          >
            <Eye className="h-3 w-3" />
            预览
          </button>
        </div>
      </div>

      {/* 编辑/预览区域 */}
      <div className="p-4">
        {mode === "edit" ? (
          <textarea
            ref={(ref) => setTextareaRef(ref)}
            value={value}
            onChange={(e) => onChange(e.target.value)}
            placeholder={placeholder}
            rows={minRows}
            className="w-full resize-none bg-transparent text-foreground placeholder:text-muted-foreground focus:outline-none leading-relaxed font-mono text-sm"
          />
        ) : (
          <div
            className="prose prose-sm max-w-none min-h-[200px] text-foreground leading-relaxed"
            dangerouslySetInnerHTML={{ __html: renderMarkdown(value) || `<span class="text-muted-foreground">${placeholder}</span>` }}
          />
        )}
      </div>

      {/* 提示信息 */}
      <div className="border-t border-border bg-muted/30 px-4 py-2">
        <p className="text-xs text-muted-foreground">
          支持 Markdown 语法: **粗体** *斜体* # 标题 - 列表 {"`代码`"} {">"} 引用
        </p>
      </div>
    </div>
  )
}
