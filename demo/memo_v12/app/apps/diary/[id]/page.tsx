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
  Cloud,
  Sun,
  CloudRain,
  Smile,
  Frown,
  Meh,
  Heart,
  Zap,
  ChevronDown,
} from "lucide-react"
import { cn } from "@/lib/utils"

type Weather = "sunny" | "cloudy" | "rainy"
type Mood = "happy" | "calm" | "sad" | "love" | "excited"

interface DiaryEntry {
  id: string
  date: string
  weather: Weather
  mood: Mood
  content: string
}

const weatherIcons: Record<Weather, typeof Sun> = {
  sunny: Sun,
  cloudy: Cloud,
  rainy: CloudRain,
}

const moodIcons: Record<Mood, typeof Smile> = {
  happy: Smile,
  calm: Meh,
  sad: Frown,
  love: Heart,
  excited: Zap,
}

const mockDiaries: Record<string, DiaryEntry> = {
  "1": {
    id: "1",
    date: "2026-03-19",
    weather: "sunny",
    mood: "happy",
    content: "今天发生了什么...",
  },
  "2": {
    id: "2",
    date: "2026-03-18",
    weather: "cloudy",
    mood: "calm",
    content: "有点疲惫，但还是坚持完成了学习计划。",
  },
  "3": {
    id: "3",
    date: "2026-03-17",
    weather: "rainy",
    mood: "calm",
    content: "下雨天，待在家里看书喝茶，很惬意。",
  },
}

export default function DiaryDetailPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = use(params)
  const router = useRouter()
  const isNew = id === "new"

  const [date, setDate] = useState("")
  const [weather, setWeather] = useState<Weather>("sunny")
  const [mood, setMood] = useState<Mood>("happy")
  const [content, setContent] = useState("")
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
    if (isNew) {
      const now = new Date()
      const y = now.getFullYear()
      const m = String(now.getMonth() + 1).padStart(2, "0")
      const d = String(now.getDate()).padStart(2, "0")
      setDate(`${y}-${m}-${d}`)
    } else if (mockDiaries[id]) {
      const diary = mockDiaries[id]
      setDate(diary.date)
      setWeather(diary.weather)
      setMood(diary.mood)
      setContent(diary.content)
    }
  }, [id, isNew])

  const handleSave = () => {
    router.back()
  }

  const formatDateDisplay = () => {
    if (!date) return ""
    const d = new Date(date + "T00:00:00")
    const weekDays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    const weekDay = weekDays[d.getDay()]
    const year = d.getFullYear()
    const month = d.getMonth() + 1
    const day = d.getDate()
    const hours = String(new Date().getHours()).padStart(2, "0")
    const minutes = String(new Date().getMinutes()).padStart(2, "0")
    return `${year}/${month}/${day} ${weekDay} ${hours}:${minutes}`
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

  const WeatherIcon = weatherIcons[weather]
  const MoodIcon = moodIcons[mood]

  return (
    <MobileLayout hideNav>
      <div className="flex min-h-screen flex-col bg-background">
        {/* 顶部导航 */}
        <header className="flex items-center justify-between border-b border-border bg-background px-4 py-3">
          <button
            onClick={() => router.back()}
            className="rounded-full p-2 text-muted-foreground hover:bg-secondary -ml-2"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <div className="flex-1" />
          <button
            onClick={handleSave}
            className="rounded-full p-2 text-primary hover:bg-primary/10 -mr-2"
          >
            <Check className="h-5 w-5" />
          </button>
        </header>

        {/* 日期和天气/心情 */}
        <div className="flex items-center justify-between border-b border-border bg-background px-4 py-2.5">
          <span className="text-sm text-muted-foreground">{formatDateDisplay()}</span>
          <div className="flex items-center gap-2">
            <WeatherIcon className="h-5 w-5 text-chart-3" />
            <MoodIcon className="h-5 w-5 text-chart-2" />
          </div>
        </div>

        {/* 内容编辑区 */}
        <div className="flex-1 p-4 overflow-y-auto">
          <textarea
            id="content-input"
            value={content}
            onChange={(e) => setContent(e.target.value)}
            placeholder="开始记录..."
            className="w-full min-h-[400px] resize-none bg-transparent text-foreground placeholder:text-muted-foreground focus:outline-none leading-relaxed"
          />
        </div>

        {/* 底部工具栏 */}
        <div className="border-t border-border bg-background">
          <div className="flex items-center gap-1 overflow-x-auto px-3 py-2.5">
            <button className="flex items-center gap-1 rounded px-2 py-1.5 text-xs text-muted-foreground hover:bg-secondary">
              <span>字号</span>
              <ChevronDown className="h-3 w-3" />
            </button>
            <div className="mx-1 h-4 w-px bg-border" />
            <button
              onClick={() => insertFormat("**", "**")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
              title="粗体"
            >
              <Bold className="h-4 w-4" />
            </button>
            <button
              onClick={() => insertFormat("*", "*")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
              title="斜体"
            >
              <Italic className="h-4 w-4" />
            </button>
            <button
              onClick={() => insertFormat("<u>", "</u>")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
              title="下划线"
            >
              <Underline className="h-4 w-4" />
            </button>
            <div className="mx-1 h-4 w-px bg-border" />
            <button
              onClick={() => insertFormat("# ")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
              title="标题1"
            >
              <Heading1 className="h-4 w-4" />
            </button>
            <button
              onClick={() => insertFormat("## ")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
              title="标题2"
            >
              <Heading2 className="h-4 w-4" />
            </button>
            <div className="mx-1 h-4 w-px bg-border" />
            <button
              onClick={() => insertFormat("- ")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
              title="无序列表"
            >
              <List className="h-4 w-4" />
            </button>
            <button
              onClick={() => insertFormat("1. ")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
              title="有序列表"
            >
              <ListOrdered className="h-4 w-4" />
            </button>
            <div className="mx-1 h-4 w-px bg-border" />
            <button
              onClick={() => insertFormat("> ")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
              title="引用"
            >
              <Quote className="h-4 w-4" />
            </button>
            <button
              onClick={() => insertFormat("`", "`")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
              title="代码"
            >
              <Code className="h-4 w-4" />
            </button>
            <button
              onClick={() => insertFormat("[", "](url)")}
              className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
              title="链接"
            >
              <Link className="h-4 w-4" />
            </button>
          </div>
        </div>
      </div>
    </MobileLayout>
  )
}
