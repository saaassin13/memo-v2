"use client"

import { useState, useEffect, use } from "react"
import { useRouter } from "next/navigation"
import { MobileLayout } from "@/components/mobile-layout"
import {
  ArrowLeft,
  Check,
  Bold,
  Italic,
  Underline,
  Heading1,
  Heading2,
  List,
  ListOrdered,
  Quote,
  Code,
  Link,
  Tag,
  Clock,
  Pin,
  ChevronDown,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { Switch } from "@/components/ui/switch"

interface Memo {
  id: string
  title: string
  content: string
  category: string
  reminderTime?: string
  pinned: boolean
}

const mockMemos: Record<string, Memo> = {
  "1": {
    id: "1",
    title: "项目会议记录",
    content: "讨论了新功能的开发计划，确定了下周的里程碑目标。\n\n主要议题\n1. 用户界面优化\n2. 性能提升方案\n3. 新功能开发排期",
    category: "工作",
    reminderTime: "2026-03-20T10:00",
    pinned: true,
  },
  "2": {
    id: "2",
    title: "购物清单",
    content: "牛奶 面包 鸡蛋 蔬菜 水果 洗衣液 纸巾",
    category: "生活",
    pinned: false,
  },
  "3": {
    id: "3",
    title: "学习笔记",
    content: "React 18 features\n- concurrent rendering\n- auto batching\n- Suspense improvements",
    category: "学习",
    pinned: false,
  },
}

const categories = ["工作", "生活", "学习"]

export default function MemoDetailPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = use(params)
  const router = useRouter()
  const isNew = id === "new"

  const [title, setTitle] = useState("")
  const [content, setContent] = useState("")
  const [category, setCategory] = useState("工作")
  const [reminderTime, setReminderTime] = useState("")
  const [pinned, setPinned] = useState(false)
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
    if (!isNew && mockMemos[id]) {
      const memo = mockMemos[id]
      setTitle(memo.title)
      setContent(memo.content)
      setCategory(memo.category)
      setReminderTime(memo.reminderTime || "")
      setPinned(memo.pinned)
    }
  }, [id, isNew])

  const handleSave = () => {
    router.back()
  }

  const insertFormat = (prefix: string, suffix: string = "") => {
    const textarea = document.getElementById("content-input") as HTMLTextAreaElement
    if (!textarea) return

    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const selectedText = content.substring(start, end)
    const newText = content.substring(0, start) + prefix + selectedText + suffix + content.substring(end)
    setContent(newText)

    setTimeout(() => {
      textarea.focus()
      textarea.setSelectionRange(start + prefix.length, end + prefix.length)
    }, 0)
  }

  if (!mounted) {
    return (
      <MobileLayout hideNav>
        <div className="flex min-h-screen items-center justify-center">
          <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
        </div>
      </MobileLayout>
    )
  }

  return (
    <MobileLayout hideNav>
      <div className="flex min-h-screen flex-col bg-background">
        {/* 顶部导航 */}
        <header className="flex items-center justify-between border-b border-border bg-background px-2 py-3">
          <button
            onClick={() => router.back()}
            className="rounded-full p-2 text-muted-foreground hover:bg-secondary"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <input
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="输入标题..."
            className="flex-1 bg-transparent text-center text-base font-medium text-foreground placeholder:text-muted-foreground focus:outline-none mx-2"
          />
          <button
            onClick={handleSave}
            className="rounded-full p-2 text-primary hover:bg-primary/10"
          >
            <Check className="h-5 w-5" />
          </button>
        </header>

        {/* 内容编辑区 */}
        <div className="flex-1 p-4">
          <textarea
            id="content-input"
            value={content}
            onChange={(e) => setContent(e.target.value)}
            placeholder="开始记录..."
            className="h-full min-h-[300px] w-full resize-none bg-transparent text-foreground placeholder:text-muted-foreground focus:outline-none leading-relaxed"
          />
        </div>

        {/* 底部工具栏和设置 */}
        <div className="border-t border-border bg-background">
          {/* Markdown 工具栏 */}
          <div className="flex items-center gap-1 overflow-x-auto border-b border-border px-3 py-2">
            <button className="flex items-center gap-1 rounded px-2 py-1.5 text-sm text-muted-foreground hover:bg-secondary">
              <span>字号</span>
              <ChevronDown className="h-3 w-3" />
            </button>
            <div className="mx-1 h-4 w-px bg-border" />
            <button
              onClick={() => insertFormat("**", "**")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
            >
              <Bold className="h-4 w-4" />
            </button>
            <button
              onClick={() => insertFormat("*", "*")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
            >
              <Italic className="h-4 w-4" />
            </button>
            <button
              onClick={() => insertFormat("<u>", "</u>")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
            >
              <Underline className="h-4 w-4" />
            </button>
            <div className="mx-1 h-4 w-px bg-border" />
            <button
              onClick={() => insertFormat("# ")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
            >
              <Heading1 className="h-4 w-4" />
            </button>
            <button
              onClick={() => insertFormat("## ")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
            >
              <Heading2 className="h-4 w-4" />
            </button>
            <div className="mx-1 h-4 w-px bg-border" />
            <button
              onClick={() => insertFormat("- ")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
            >
              <List className="h-4 w-4" />
            </button>
            <button
              onClick={() => insertFormat("1. ")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
            >
              <ListOrdered className="h-4 w-4" />
            </button>
            <button
              onClick={() => insertFormat("> ")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
            >
              <Quote className="h-4 w-4" />
            </button>
            <button
              onClick={() => insertFormat("`", "`")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
            >
              <Code className="h-4 w-4" />
            </button>
            <button
              onClick={() => insertFormat("[", "](url)")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
            >
              <Link className="h-4 w-4" />
            </button>
          </div>

          {/* 设置区域 */}
          <div className="space-y-0">
            {/* 分类 */}
            <div className="flex items-center justify-between px-4 py-3 border-b border-border">
              <div className="flex items-center gap-2 text-muted-foreground">
                <Tag className="h-4 w-4" />
                <span className="text-sm">分类</span>
              </div>
              <div className="flex gap-2">
                {categories.map((cat) => (
                  <button
                    key={cat}
                    onClick={() => setCategory(cat)}
                    className={cn(
                      "rounded-full px-3 py-1 text-sm transition-colors",
                      category === cat
                        ? "bg-primary text-primary-foreground"
                        : "bg-secondary text-muted-foreground hover:text-foreground"
                    )}
                  >
                    {cat}
                  </button>
                ))}
              </div>
            </div>

            {/* 提醒时间 */}
            <div className="flex items-center justify-between px-4 py-3 border-b border-border">
              <div className="flex items-center gap-2 text-muted-foreground">
                <Clock className="h-4 w-4" />
                <span className="text-sm">提醒时间</span>
              </div>
              <input
                type="datetime-local"
                value={reminderTime}
                onChange={(e) => setReminderTime(e.target.value)}
                className="bg-transparent text-sm text-muted-foreground focus:outline-none"
              />
            </div>

            {/* 置顶 */}
            <div className="flex items-center justify-between px-4 py-3">
              <div className="flex items-center gap-2 text-muted-foreground">
                <Pin className="h-4 w-4" />
                <span className="text-sm">置顶</span>
              </div>
              <Switch checked={pinned} onCheckedChange={setPinned} />
            </div>
          </div>
        </div>
      </div>
    </MobileLayout>
  )
}
