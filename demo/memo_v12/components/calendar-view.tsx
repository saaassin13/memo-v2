"use client"

import { useMemo, useState, useEffect } from "react"
import type { CalendarEvent } from "@/app/calendar/page"
import { EventCard } from "@/components/event-card"
import { cn } from "@/lib/utils"
import { ChevronLeft, ChevronRight } from "lucide-react"

interface CalendarViewProps {
  viewMode: "day" | "week" | "month"
  selectedDate: Date
  onSelectDate: (date: Date) => void
  events: CalendarEvent[]
  onEventClick?: (event: CalendarEvent) => void
}

const weekDays = ["日", "一", "二", "三", "四", "五", "六"]

export function CalendarView({
  viewMode,
  selectedDate,
  onSelectDate,
  events,
  onEventClick,
}: CalendarViewProps) {
  const [mounted, setMounted] = useState(false)
  const [todayStr, setTodayStr] = useState<string>("")

  useEffect(() => {
    const now = new Date()
    now.setHours(0, 0, 0, 0)
    setTodayStr(now.toDateString())
    setMounted(true)
  }, [])

  const monthDays = useMemo(() => {
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
    return days
  }, [selectedDate])

  const weekDates = useMemo(() => {
    const dates: Date[] = []
    const start = new Date(selectedDate)
    start.setDate(start.getDate() - start.getDay())
    for (let i = 0; i < 7; i++) {
      const d = new Date(start)
      d.setDate(start.getDate() + i)
      dates.push(d)
    }
    return dates
  }, [selectedDate])

  const getEventsForDate = (date: Date) => {
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, "0")
    const d = String(date.getDate()).padStart(2, "0")
    const dateStr = `${y}-${m}-${d}`
    return events.filter((e) => e.date === dateStr)
  }

  const navigateMonth = (delta: number) => {
    const newDate = new Date(selectedDate)
    newDate.setMonth(newDate.getMonth() + delta)
    onSelectDate(newDate)
  }

  const isToday = (date: Date) => {
    if (!todayStr) return false
    return date.toDateString() === todayStr
  }

  const isSelected = (date: Date) => {
    return date.toDateString() === selectedDate.toDateString()
  }

  // 日视图：去掉时间轴，改为卡片列表
  if (viewMode === "day") {
    const dayEvents = getEventsForDate(selectedDate)
    return (
      <div className="p-4">
        <div className="mb-4 flex items-center justify-between">
          <button
            onClick={() => {
              const d = new Date(selectedDate)
              d.setDate(d.getDate() - 1)
              onSelectDate(d)
            }}
            className="rounded-full p-2 hover:bg-secondary"
          >
            <ChevronLeft className="h-5 w-5" />
          </button>
          <div className="text-center">
            <h2 className="text-lg font-semibold">
              {selectedDate.toLocaleDateString("zh-CN", {
                month: "long",
                day: "numeric",
              })}
            </h2>
            <p className="text-xs text-muted-foreground">
              {selectedDate.toLocaleDateString("zh-CN", { weekday: "long" })}
            </p>
          </div>
          <button
            onClick={() => {
              const d = new Date(selectedDate)
              d.setDate(d.getDate() + 1)
              onSelectDate(d)
            }}
            className="rounded-full p-2 hover:bg-secondary"
          >
            <ChevronRight className="h-5 w-5" />
          </button>
        </div>

        {dayEvents.length > 0 ? (
          <div className="space-y-3">
            {dayEvents.map((event) => (
              <EventCard
                key={event.id}
                event={event}
                onClick={() => onEventClick?.(event)}
              />
            ))}
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center py-16 text-muted-foreground">
            <p className="text-sm">暂无事件</p>
          </div>
        )}
      </div>
    )
  }

  if (viewMode === "week") {
    return (
      <div className="p-4">
        <div className="mb-4 flex items-center justify-between">
          <button
            onClick={() => {
              const d = new Date(selectedDate)
              d.setDate(d.getDate() - 7)
              onSelectDate(d)
            }}
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
            onClick={() => {
              const d = new Date(selectedDate)
              d.setDate(d.getDate() + 7)
              onSelectDate(d)
            }}
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
          {weekDates.map((date, i) => {
            const dayEvents = mounted ? getEventsForDate(date) : []
            return (
              <button
                key={i}
                onClick={() => onSelectDate(date)}
                className={cn(
                  "flex flex-col items-center rounded-lg p-2 transition-colors",
                  isSelected(date)
                    ? "bg-primary text-primary-foreground"
                    : mounted && isToday(date)
                      ? "bg-primary/10 text-primary"
                      : "hover:bg-secondary"
                )}
              >
                <span className="text-sm font-medium">{date.getDate()}</span>
                <div className="mt-1 h-1.5 flex items-center gap-0.5">
                  {dayEvents.slice(0, 3).map((_, idx) => (
                    <div
                      key={idx}
                      className={cn(
                        "h-1 w-1 rounded-full",
                        isSelected(date) ? "bg-primary-foreground" : "bg-primary"
                      )}
                    />
                  ))}
                </div>
              </button>
            )
          })}
        </div>
      </div>
    )
  }

  return (
    <div className="p-4">
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
        {monthDays.map((date, i) => {
          if (!date) {
            return <div key={i} />
          }
          // 服务端不计算事件，避免水合不匹配
          const dayEvents = mounted ? getEventsForDate(date) : []
          return (
            <button
              key={i}
              onClick={() => onSelectDate(date)}
              className={cn(
                "flex flex-col items-center rounded-lg p-2 transition-colors",
                isSelected(date)
                  ? "bg-primary text-primary-foreground"
                  : mounted && isToday(date)
                    ? "bg-primary/10 text-primary"
                    : "hover:bg-secondary"
              )}
            >
              <span className="text-sm">{date.getDate()}</span>
              {/* 固定占位高度，避免有无指示点导致布局跳动 */}
              <div className="mt-1 h-1.5 flex items-center gap-0.5">
                {dayEvents.slice(0, 3).map((_, idx) => (
                  <div
                    key={idx}
                    className={cn(
                      "h-1 w-1 rounded-full",
                      isSelected(date) ? "bg-primary-foreground" : "bg-primary"
                    )}
                  />
                ))}
              </div>
            </button>
          )
        })}
      </div>
    </div>
  )
}
