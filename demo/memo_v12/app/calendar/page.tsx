"use client"

import { useState, useEffect } from "react"
import { MobileLayout } from "@/components/mobile-layout"
import { CalendarView } from "@/components/calendar-view"
import { EventCard } from "@/components/event-card"
import { Plus, Settings, X, Check } from "lucide-react"
import { cn } from "@/lib/utils"
import { useRouter } from "next/navigation"

type ViewMode = "day" | "week" | "month"

const viewModes: { value: ViewMode; label: string }[] = [
  { value: "day", label: "日" },
  { value: "week", label: "周" },
  { value: "month", label: "月" },
]

export type EventType = "memo" | "diary" | "todo" | "goal" | "weight"

export const eventTypeConfig: Record<EventType, { label: string; color: string }> = {
  memo: { label: "备忘", color: "bg-primary/10 text-primary" },
  diary: { label: "日记", color: "bg-chart-2/10 text-chart-2" },
  todo: { label: "待办", color: "bg-accent/10 text-accent" },
  goal: { label: "目标", color: "bg-chart-1/10 text-chart-1" },
  weight: { label: "体重", color: "bg-chart-5/10 text-chart-5" },
}

export interface CalendarEvent {
  id: string
  title: string
  type: EventType
  date: string
  time?: string
  description?: string
}

const mockEvents: CalendarEvent[] = [
  {
    id: "1",
    title: "完成项目报告",
    type: "todo",
    date: "2026-03-19",
    time: "14:00",
  },
  {
    id: "2",
    title: "今天心情不错",
    type: "diary",
    date: "2026-03-19",
    description: "春光明媚，工作顺利",
  },
  {
    id: "3",
    title: "会议备忘",
    type: "memo",
    date: "2026-03-19",
    time: "10:00",
  },
  {
    id: "4",
    title: "健身目标",
    type: "goal",
    date: "2026-03-19",
    description: "进度 60%",
  },
  {
    id: "5",
    title: "体重记录",
    type: "weight",
    date: "2026-03-19",
    description: "68.5 kg",
  },
  {
    id: "6",
    title: "读书笔记",
    type: "memo",
    date: "2026-03-18",
  },
  {
    id: "7",
    title: "跑步计划",
    type: "goal",
    date: "2026-03-18",
    description: "进度 40%",
  },
]

const allTypes: EventType[] = ["memo", "diary", "todo", "goal", "weight"]

// 使用固定的初始日期字符串避免水合错误
const INITIAL_DATE = "2026-03-19"

export default function CalendarPage() {
  const [viewMode, setViewMode] = useState<ViewMode>("month")
  const [selectedDate, setSelectedDate] = useState<Date | null>(null)
  const [showSettings, setShowSettings] = useState(false)
  const [activeFilters, setActiveFilters] = useState<EventType[]>([...allTypes])
  const router = useRouter()

  useEffect(() => {
    setSelectedDate(new Date())
  }, [])

  // 在客户端水合完成前显示加载状态
  if (!selectedDate) {
    return (
      <MobileLayout>
        <div className="flex min-h-screen items-center justify-center">
          <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
        </div>
      </MobileLayout>
    )
  }

  const dateStr = selectedDate.toISOString().split("T")[0]
  const todayEvents = mockEvents.filter(
    (e) => e.date === dateStr && activeFilters.includes(e.type)
  )

  const filteredEvents = mockEvents.filter((e) => activeFilters.includes(e.type))

  const toggleFilter = (type: EventType) => {
    setActiveFilters((prev) =>
      prev.includes(type) ? prev.filter((t) => t !== type) : [...prev, type]
    )
  }

  const handleEventClick = (event: CalendarEvent) => {
    switch (event.type) {
      case "memo":
        router.push(`/apps/memo/${event.id}`)
        break
      case "diary":
        router.push(`/apps/diary/${event.id}`)
        break
      case "goal":
        router.push(`/apps/goals/${event.id}`)
        break
      case "todo":
        router.push(`/todo`)
        break
      case "weight":
        router.push(`/apps/weight`)
        break
      default:
        break
    }
  }

  return (
    <MobileLayout>
      <div className="flex flex-col">
        <header className="sticky top-0 z-40 border-b border-border bg-card/95 backdrop-blur-md">
          <div className="flex items-center justify-between px-4 py-3">
            <div className="flex gap-1 rounded-lg bg-secondary p-1">
              {viewModes.map((mode) => (
                <button
                  key={mode.value}
                  onClick={() => setViewMode(mode.value)}
                  className={cn(
                    "rounded-md px-4 py-1.5 text-sm font-medium transition-colors",
                    viewMode === mode.value
                      ? "bg-card text-foreground shadow-sm"
                      : "text-muted-foreground hover:text-foreground"
                  )}
                >
                  {mode.label}
                </button>
              ))}
            </div>
            <button
              onClick={() => setShowSettings(!showSettings)}
              className={cn(
                "rounded-full p-2 transition-colors",
                showSettings
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground hover:bg-secondary hover:text-foreground"
              )}
            >
              <Settings className="h-5 w-5" />
            </button>
          </div>

          {/* 筛选面板 */}
          {showSettings && (
            <div className="border-t border-border px-4 py-3">
              <div className="mb-2 flex items-center justify-between">
                <span className="text-xs font-medium text-muted-foreground">显示内容</span>
                <button
                  onClick={() => setShowSettings(false)}
                  className="rounded-full p-1 text-muted-foreground hover:bg-secondary"
                >
                  <X className="h-3.5 w-3.5" />
                </button>
              </div>
              <div className="flex flex-wrap gap-2">
                {allTypes.map((type) => {
                  const config = eventTypeConfig[type]
                  const active = activeFilters.includes(type)
                  return (
                    <button
                      key={type}
                      onClick={() => toggleFilter(type)}
                      className={cn(
                        "flex items-center gap-1.5 rounded-full border px-3 py-1.5 text-xs font-medium transition-all",
                        active
                          ? "border-primary/30 bg-primary/10 text-primary"
                          : "border-border bg-secondary text-muted-foreground"
                      )}
                    >
                      {active && <Check className="h-3 w-3" />}
                      {config.label}
                    </button>
                  )
                })}
              </div>
            </div>
          )}
        </header>

        <div className="flex-1">
          <CalendarView
            viewMode={viewMode}
            selectedDate={selectedDate}
            onSelectDate={setSelectedDate}
            events={filteredEvents}
            onEventClick={handleEventClick}
          />

          {viewMode !== "day" && (
            <div className="border-t border-border p-4">
              <h3 className="mb-3 text-sm font-medium text-muted-foreground">
                {selectedDate.toLocaleDateString("zh-CN", {
                  month: "long",
                  day: "numeric",
                  weekday: "long",
                })}
              </h3>
              {todayEvents.length > 0 ? (
                <div className="space-y-3">
                  {todayEvents.map((event) => (
                    <EventCard
                      key={event.id}
                      event={event}
                      onClick={() => handleEventClick(event)}
                    />
                  ))}
                </div>
              ) : (
                <p className="py-8 text-center text-sm text-muted-foreground">
                  暂无事件
                </p>
              )}
            </div>
          )}
        </div>

        <button className="fixed bottom-24 right-4 z-40 flex h-14 w-14 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg transition-transform hover:scale-105 active:scale-95">
          <Plus className="h-6 w-6" />
        </button>
      </div>
    </MobileLayout>
  )
}
