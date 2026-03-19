"use client"

import { useState, useRef, useEffect } from "react"
import { useRouter } from "next/navigation"
import Link from "next/link"
import { 
  ArrowLeft, 
  Check, 
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
  Type,
  ChevronDown,
  Sun,
  Cloud,
  CloudRain,
  CloudSnow,
  CloudLightning,
  Wind,
  Smile,
  Frown,
  Meh,
  Heart,
  Angry,
  Laugh
} from "lucide-react"
import { Textarea } from "@/components/ui/textarea"
import { cn } from "@/lib/utils"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import {
  Drawer,
  DrawerContent,
  DrawerDescription,
  DrawerHeader,
  DrawerTitle,
} from "@/components/ui/drawer"

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

const weatherOptions = [
  { icon: Sun, label: "晴天", value: "sunny", color: "text-amber-500" },
  { icon: Cloud, label: "多云", value: "cloudy", color: "text-gray-400" },
  { icon: CloudRain, label: "下雨", value: "rainy", color: "text-blue-400" },
  { icon: CloudSnow, label: "下雪", value: "snowy", color: "text-sky-300" },
  { icon: CloudLightning, label: "雷电", value: "thunder", color: "text-yellow-500" },
  { icon: Wind, label: "大风", value: "windy", color: "text-teal-400" },
]

const moodOptions = [
  { icon: Laugh, label: "开心", value: "happy", color: "text-yellow-500" },
  { icon: Smile, label: "愉快", value: "pleased", color: "text-green-500" },
  { icon: Heart, label: "心动", value: "love", color: "text-pink-500" },
  { icon: Meh, label: "平静", value: "calm", color: "text-blue-400" },
  { icon: Frown, label: "难过", value: "sad", color: "text-indigo-400" },
  { icon: Angry, label: "生气", value: "angry", color: "text-red-500" },
]

const weekDays = ["日", "一", "二", "三", "四", "五", "六"]

function formatDateTime(date: Date) {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, "0")
  const day = String(date.getDate()).padStart(2, "0")
  const weekDay = weekDays[date.getDay()]
  const hours = String(date.getHours()).padStart(2, "0")
  const minutes = String(date.getMinutes()).padStart(2, "0")
  
  return `${year}/${month}/${day} 周${weekDay} ${hours}:${minutes}`
}

export default function NewDiaryPage() {
  const router = useRouter()
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const [content, setContent] = useState("")
  const [fontSize, setFontSize] = useState("text-base")
  const [fontSizeOpen, setFontSizeOpen] = useState(false)
  const [settingsOpen, setSettingsOpen] = useState(false)
  const [weather, setWeather] = useState("sunny")
  const [mood, setMood] = useState("happy")
  const [currentTime, setCurrentTime] = useState<Date | null>(null)
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setCurrentTime(new Date())
    setMounted(true)
    const timer = setInterval(() => {
      setCurrentTime(new Date())
    }, 60000)
    return () => clearInterval(timer)
  }, [])

  const handleSave = () => {
    if (!content.trim()) return
    router.push("/apps/diary")
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
      newText = content.substring(0, start) + format.prefix + selectedText + format.suffix + content.substring(end)
      newCursorPos = selectedText ? end + format.prefix.length + format.suffix.length : start + format.prefix.length
    } else {
      const lineStart = content.lastIndexOf('\n', start - 1) + 1
      newText = content.substring(0, lineStart) + format.prefix + content.substring(lineStart)
      newCursorPos = start + format.prefix.length
    }

    setContent(newText)
    
    setTimeout(() => {
      textarea.focus()
      textarea.setSelectionRange(newCursorPos, newCursorPos)
    }, 0)
  }

  const selectedWeather = weatherOptions.find(w => w.value === weather)
  const selectedMood = moodOptions.find(m => m.value === mood)
  const WeatherIcon = selectedWeather?.icon || Sun
  const MoodIcon = selectedMood?.icon || Smile

  if (!mounted || !currentTime) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
      </div>
    )
  }

  return (
    <div className="flex min-h-screen flex-col bg-background">
      <header className="sticky top-0 z-40 flex items-center justify-between border-b border-border bg-card/95 px-4 py-3 backdrop-blur-md">
        <Link
          href="/apps/diary"
          className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
        >
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <button
          onClick={handleSave}
          disabled={!content.trim()}
          className={cn(
            "rounded-full p-2 transition-colors",
            content.trim()
              ? "text-primary hover:bg-primary/10"
              : "text-muted-foreground"
          )}
        >
          <Check className="h-5 w-5" />
        </button>
      </header>

      {/* 日期时间和天气心情 */}
      <div className="flex items-center justify-between border-b border-border bg-card px-4 py-3">
        <div className="text-sm font-medium text-foreground">
          {formatDateTime(currentTime)}
        </div>
        <button
          onClick={() => setSettingsOpen(true)}
          className="flex items-center gap-2 rounded-full bg-secondary px-3 py-1.5 transition-colors hover:bg-secondary/80"
        >
          <WeatherIcon className={cn("h-4 w-4", selectedWeather?.color)} />
          <MoodIcon className={cn("h-4 w-4", selectedMood?.color)} />
        </button>
      </div>

      <div className="flex-1 p-4">
        <Textarea
          ref={textareaRef}
          placeholder="今天发生了什么..."
          value={content}
          onChange={(e) => setContent(e.target.value)}
          className={cn(
            "min-h-[300px] resize-none border-0 bg-transparent focus-visible:ring-0",
            fontSize
          )}
        />
      </div>

      {/* 格式工具栏 */}
      <div className="sticky bottom-0 z-30 border-t border-border bg-card pb-[env(safe-area-inset-bottom)]">
        <div className="flex items-center gap-1 overflow-x-auto px-2 py-2 scrollbar-hide">
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

      {/* 天气心情选择 Drawer */}
      <Drawer open={settingsOpen} onOpenChange={setSettingsOpen}>
        <DrawerContent>
          <DrawerHeader>
            <DrawerTitle>天气与心情</DrawerTitle>
            <DrawerDescription>选择今天的天气和此刻的心情</DrawerDescription>
          </DrawerHeader>
          <div className="px-4 pb-8 space-y-6">
            <div>
              <h3 className="text-sm font-medium text-foreground mb-3">今日天气</h3>
              <div className="grid grid-cols-6 gap-2">
                {weatherOptions.map((option) => {
                  const Icon = option.icon
                  return (
                    <button
                      key={option.value}
                      onClick={() => setWeather(option.value)}
                      className={cn(
                        "flex flex-col items-center gap-1.5 rounded-xl p-3 transition-colors",
                        weather === option.value
                          ? "bg-primary/10 ring-2 ring-primary"
                          : "bg-secondary hover:bg-secondary/80"
                      )}
                    >
                      <Icon className={cn("h-6 w-6", option.color)} />
                      <span className="text-xs font-medium text-foreground">{option.label}</span>
                    </button>
                  )
                })}
              </div>
            </div>
            <div>
              <h3 className="text-sm font-medium text-foreground mb-3">此刻心情</h3>
              <div className="grid grid-cols-6 gap-2">
                {moodOptions.map((option) => {
                  const Icon = option.icon
                  return (
                    <button
                      key={option.value}
                      onClick={() => setMood(option.value)}
                      className={cn(
                        "flex flex-col items-center gap-1.5 rounded-xl p-3 transition-colors",
                        mood === option.value
                          ? "bg-primary/10 ring-2 ring-primary"
                          : "bg-secondary hover:bg-secondary/80"
                      )}
                    >
                      <Icon className={cn("h-6 w-6", option.color)} />
                      <span className="text-xs font-medium text-foreground">{option.label}</span>
                    </button>
                  )
                })}
              </div>
            </div>
          </div>
        </DrawerContent>
      </Drawer>
    </div>
  )
}
