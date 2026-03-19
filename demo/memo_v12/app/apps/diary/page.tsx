"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { ArrowLeft, Plus, Cloud, Sun, CloudRain, ChevronLeft, ChevronRight } from "lucide-react"
import { cn } from "@/lib/utils"

interface DiaryEntry {
  id: string
  date: string
  weather: "sunny" | "cloudy" | "rainy"
  content: string
  mood: string
}

const mockEntries: DiaryEntry[] = [
  {
    id: "1",
    date: "2026-03-18",
    weather: "sunny",
    content: "今天是美好的一天，完成了很多工作任务，晚上和朋友一起吃了火锅...",
    mood: "开心",
  },
  {
    id: "2",
    date: "2026-03-17",
    weather: "cloudy",
    content: "有点疲惫，但还是坚持完成了学习计划...",
    mood: "平静",
  },
  {
    id: "3",
    date: "2026-03-15",
    weather: "rainy",
    content: "下雨天，待在家里看书喝茶，很惬意...",
    mood: "放松",
  },
]

const weatherIcons = {
  sunny: Sun,
  cloudy: Cloud,
  rainy: CloudRain,
}

const weekDays = ["日", "一", "二", "三", "四", "五", "六"]

export default function DiaryPage() {
  const [mounted, setMounted] = useState(false)
  const [selectedDate, setSelectedDate] = useState<Date | null>(null)

  useEffect(() => {
    setSelectedDate(new Date())
    setMounted(true)
  }, [])

  if (!mounted || !selectedDate) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
      </div>
    )
  }

  const today = new Date()
  today.setHours(0, 0, 0, 0)

  const year = selectedDate.getFullYear()
  const month = selectedDate.getMonth()
  const firstDay = new Date(year, month, 1)
  const lastDay = new Date(year, month + 1, 0)
  const startPadding = firstDay.getDay()

  const days: (Date | null)[] = []
  for (let i = 0; i < startPadding; i++) {
    days.push(null)
  }
  for (let i = 1; i <= lastDay.getDate(); i++) {
    days.push(new Date(year, month, i))
  }

  const navigateMonth = (delta: number) => {
    const newDate = new Date(selectedDate)
    newDate.setMonth(newDate.getMonth() + delta)
    setSelectedDate(newDate)
  }

  const getEntryForDate = (date: Date) => {
    const dateStr = date.toISOString().split("T")[0]
    return mockEntries.find((e) => e.date === dateStr)
  }

  const selectedEntry = getEntryForDate(selectedDate)

  return (
    <div className="flex min-h-screen flex-col bg-background">
      <header className="sticky top-0 z-40 flex items-center justify-between border-b border-border bg-card/95 px-4 py-3 backdrop-blur-md">
        <div className="flex items-center gap-3">
          <Link
            href="/"
            className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
          >
            <ArrowLeft className="h-5 w-5" />
          </Link>
          <h1 className="text-xl font-semibold text-foreground">日记</h1>
        </div>
        <Link
          href="/apps/diary/new"
          className="rounded-full bg-primary px-4 py-1.5 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
        >
          写日记
        </Link>
      </header>

      <div className="border-b border-border bg-card p-4">
        <div className="mb-4 flex items-center justify-between">
          <button
            onClick={() => navigateMonth(-1)}
            className="rounded-full p-2 hover:bg-secondary"
          >
            <ChevronLeft className="h-5 w-5" />
          </button>
          <h2 className="text-lg font-semibold">
            {selectedDate.toLocaleDateString("zh-CN", {
              year: "numeric",
              month: "long",
            })}
          </h2>
          <button
            onClick={() => navigateMonth(1)}
            className="rounded-full p-2 hover:bg-secondary"
          >
            <ChevronRight className="h-5 w-5" />
          </button>
        </div>
        <div className="grid grid-cols-7 gap-1">
          {weekDays.map((day) => (
            <div
              key={day}
              className="py-2 text-center text-xs font-medium text-muted-foreground"
            >
              {day}
            </div>
          ))}
          {days.map((date, i) => {
            if (!date) return <div key={i} />
            const entry = getEntryForDate(date)
            const isToday = date.toDateString() === today.toDateString()
            const isSelected = date.toDateString() === selectedDate.toDateString()
            return (
              <button
                key={i}
                onClick={() => setSelectedDate(date)}
                className={cn(
                  "flex flex-col items-center rounded-lg p-2 transition-colors",
                  isSelected
                    ? "bg-primary text-primary-foreground"
                    : isToday
                      ? "bg-primary/10 text-primary"
                      : "hover:bg-secondary"
                )}
              >
                <span className="text-sm">{date.getDate()}</span>
                {entry && (
                  <div
                    className={cn(
                      "mt-1 h-1.5 w-1.5 rounded-full",
                      isSelected ? "bg-primary-foreground" : "bg-accent"
                    )}
                  />
                )}
              </button>
            )
          })}
        </div>
      </div>

      <div className="flex-1 p-4">
        {selectedEntry ? (
          <Link
            href={`/apps/diary/${selectedEntry.id}`}
            className="block rounded-xl bg-card p-4 shadow-sm transition-colors hover:bg-card/80"
          >
            <div className="mb-3 flex items-center justify-between">
              <div className="flex items-center gap-2">
                {(() => {
                  const WeatherIcon = weatherIcons[selectedEntry.weather]
                  return <WeatherIcon className="h-5 w-5 text-chart-3" />
                })()}
                <span className="text-sm text-muted-foreground">
                  {selectedEntry.mood}
                </span>
              </div>
              <span className="text-sm text-muted-foreground">
                {selectedEntry.date}
              </span>
            </div>
            <p className="text-foreground leading-relaxed">{selectedEntry.content}</p>
            <p className="mt-2 text-xs text-muted-foreground">点击查看或编辑</p>
          </Link>
        ) : (
          <div className="flex flex-col items-center justify-center py-12">
            <p className="mb-4 text-muted-foreground">这一天还没有日记</p>
            <Link
              href="/apps/diary/new"
              className="flex items-center gap-2 rounded-full bg-primary px-4 py-2 text-sm font-medium text-primary-foreground"
            >
              <Plus className="h-4 w-4" />
              写日记
            </Link>
          </div>
        )}

        <div className="mt-6">
          <h3 className="mb-3 text-sm font-medium text-muted-foreground">
            历史日记
          </h3>
          <div className="space-y-3">
            {mockEntries.map((entry) => {
              const WeatherIcon = weatherIcons[entry.weather]
              return (
                <Link
                  key={entry.id}
                  href={`/apps/diary/${entry.id}`}
                  className="block rounded-xl bg-card p-4 shadow-sm transition-colors hover:bg-card/80"
                >
                  <div className="mb-2 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <WeatherIcon className="h-4 w-4 text-chart-3" />
                      <span className="text-xs text-muted-foreground">
                        {entry.mood}
                      </span>
                    </div>
                    <span className="text-xs text-muted-foreground">
                      {entry.date}
                    </span>
                  </div>
                  <p className="line-clamp-2 text-sm text-foreground">
                    {entry.content}
                  </p>
                </Link>
              )
            })}
          </div>
        </div>
      </div>
    </div>
  )
}
