"use client"

import { useState, useRef } from "react"
import { useRouter } from "next/navigation"
import Link from "next/link"
import { 
  ArrowLeft, 
  Check, 
  Clock, 
  Pin, 
  Tag, 
  Bold, 
  Italic, 
  Underline, 
  List, 
  ListOrdered, 
  Heading1, 
  Heading2, 
  Quote, 
  Code, 
  Link2, 
  Image,
  Type,
  ChevronDown
} from "lucide-react"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { cn } from "@/lib/utils"
import { Switch } from "@/components/ui/switch"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"

const categories = ["工作", "生活", "学习"]

const fontSizes = [
  { label: "小", value: "text-sm" },
  { label: "标准", value: "text-base" },
  { label: "大", value: "text-lg" },
  { label: "特大", value: "text-xl" },
]

interface FormatButton {
  icon: React.ElementType
  label: string
  action: string
  prefix?: string
  suffix?: string
}

const formatButtons: FormatButton[] = [
  { icon: Bold, label: "粗体", action: "bold", prefix: "**", suffix: "**" },
  { icon: Italic, label: "斜体", action: "italic", prefix: "*", suffix: "*" },
  { icon: Underline, label: "下划线", action: "underline", prefix: "<u>", suffix: "</u>" },
  { icon: Heading1, label: "标题1", action: "h1", prefix: "# ", suffix: "" },
  { icon: Heading2, label: "标题2", action: "h2", prefix: "## ", suffix: "" },
  { icon: List, label: "无序列表", action: "ul", prefix: "- ", suffix: "" },
  { icon: ListOrdered, label: "有序列表", action: "ol", prefix: "1. ", suffix: "" },
  { icon: Quote, label: "引用", action: "quote", prefix: "> ", suffix: "" },
  { icon: Code, label: "代码", action: "code", prefix: "`", suffix: "`" },
  { icon: Link2, label: "链接", action: "link", prefix: "[", suffix: "](url)" },
]

export default function NewMemoPage() {
  const router = useRouter()
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const [title, setTitle] = useState("")
  const [content, setContent] = useState("")
  const [category, setCategory] = useState("工作")
  const [pinned, setPinned] = useState(false)
  const [reminder, setReminder] = useState("")
  const [fontSize, setFontSize] = useState("text-base")
  const [fontSizeOpen, setFontSizeOpen] = useState(false)

  const handleSave = () => {
    if (!title.trim()) return
    // 保存逻辑
    router.push("/apps/memo")
  }

  const insertFormat = (format: FormatButton) => {
    const textarea = textareaRef.current
    if (!textarea) return

    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const selectedText = content.substring(start, end)
    
    let newText: string
    let newCursorPos: number

    if (format.suffix) {
      // 包裹选中文本
      newText = content.substring(0, start) + format.prefix + selectedText + format.suffix + content.substring(end)
      newCursorPos = selectedText ? end + format.prefix.length + format.suffix.length : start + format.prefix.length
    } else {
      // 行首插入
      const lineStart = content.lastIndexOf('\n', start - 1) + 1
      newText = content.substring(0, lineStart) + format.prefix + content.substring(lineStart)
      newCursorPos = start + format.prefix.length
    }

    setContent(newText)
    
    // 恢复焦点和光标位置
    setTimeout(() => {
      textarea.focus()
      textarea.setSelectionRange(newCursorPos, newCursorPos)
    }, 0)
  }

  return (
    <div className="flex min-h-screen flex-col bg-background">
      <header className="sticky top-0 z-40 flex items-center justify-between border-b border-border bg-card/95 px-4 py-3 backdrop-blur-md">
        <Link
          href="/apps/memo"
          className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
        >
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <Input
          placeholder="输入标题..."
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          className="mx-4 flex-1 border-0 bg-transparent text-center text-lg font-medium focus-visible:ring-0"
        />
        <button
          onClick={handleSave}
          disabled={!title.trim()}
          className={cn(
            "rounded-full p-2 transition-colors",
            title.trim()
              ? "text-primary hover:bg-primary/10"
              : "text-muted-foreground"
          )}
        >
          <Check className="h-5 w-5" />
        </button>
      </header>

      <div className="flex-1 p-4">
        <Textarea
          ref={textareaRef}
          placeholder="开始记录..."
          value={content}
          onChange={(e) => setContent(e.target.value)}
          className={cn(
            "min-h-[300px] resize-none border-0 bg-transparent focus-visible:ring-0",
            fontSize
          )}
        />
      </div>

      {/* 格式工具栏 */}
      <div className="sticky bottom-[calc(theme(spacing.16)+env(safe-area-inset-bottom))] z-30 border-t border-border bg-card">
        <div className="flex items-center gap-1 overflow-x-auto px-2 py-2 scrollbar-hide">
          {/* 字体大小选择 */}
          <Popover open={fontSizeOpen} onOpenChange={setFontSizeOpen}>
            <PopoverTrigger asChild>
              <button className="flex shrink-0 items-center gap-1 rounded-lg px-3 py-2 text-sm font-medium text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground">
                <Type className="h-4 w-4" />
                <span className="text-xs">字号</span>
                <ChevronDown className="h-3 w-3" />
              </button>
            </PopoverTrigger>
            <PopoverContent className="w-32 p-1" align="start">
              {fontSizes.map((size) => (
                <button
                  key={size.value}
                  onClick={() => {
                    setFontSize(size.value)
                    setFontSizeOpen(false)
                  }}
                  className={cn(
                    "flex w-full items-center justify-between rounded-md px-3 py-2 text-sm transition-colors",
                    fontSize === size.value
                      ? "bg-primary/10 text-primary"
                      : "hover:bg-secondary"
                  )}
                >
                  <span>{size.label}</span>
                  {fontSize === size.value && <Check className="h-4 w-4" />}
                </button>
              ))}
            </PopoverContent>
          </Popover>

          <div className="mx-1 h-6 w-px bg-border" />

          {/* 格式按钮 */}
          {formatButtons.map((format) => {
            const Icon = format.icon
            return (
              <button
                key={format.action}
                onClick={() => insertFormat(format)}
                className="shrink-0 rounded-lg p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
                title={format.label}
              >
                <Icon className="h-4 w-4" />
              </button>
            )
          })}
        </div>
      </div>

      {/* 设置面板 */}
      <div className="border-t border-border bg-card p-4 pb-[calc(theme(spacing.4)+env(safe-area-inset-bottom))]">
        <div className="space-y-4">
          <div className="flex items-center gap-3">
            <Tag className="h-5 w-5 text-muted-foreground" />
            <span className="text-sm text-foreground">分类</span>
            <div className="ml-auto flex gap-2">
              {categories.map((cat) => (
                <button
                  key={cat}
                  onClick={() => setCategory(cat)}
                  className={cn(
                    "rounded-full px-3 py-1 text-xs font-medium transition-colors",
                    category === cat
                      ? "bg-primary text-primary-foreground"
                      : "bg-secondary text-secondary-foreground"
                  )}
                >
                  {cat}
                </button>
              ))}
            </div>
          </div>
          <div className="flex items-center gap-3">
            <Clock className="h-5 w-5 text-muted-foreground" />
            <span className="text-sm text-foreground">提醒时间</span>
            <Input
              type="datetime-local"
              value={reminder}
              onChange={(e) => setReminder(e.target.value)}
              className="ml-auto w-auto"
            />
          </div>
          <div className="flex items-center gap-3">
            <Pin className="h-5 w-5 text-muted-foreground" />
            <span className="text-sm text-foreground">置顶</span>
            <Switch
              checked={pinned}
              onCheckedChange={setPinned}
              className="ml-auto"
            />
          </div>
        </div>
      </div>
    </div>
  )
}
