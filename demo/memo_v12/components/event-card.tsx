"use client"

import type { CalendarEvent } from "@/app/calendar/page"
import { cn } from "@/lib/utils"
import {
  FileText,
  BookOpen,
  CheckSquare,
  Target,
  Scale,
  ChevronRight,
} from "lucide-react"

interface EventCardProps {
  event: CalendarEvent
  onClick?: () => void
}

const eventConfig = {
  memo: {
    icon: FileText,
    color: "bg-primary/10 text-primary border-primary/20",
    label: "备忘",
  },
  diary: {
    icon: BookOpen,
    color: "bg-chart-2/10 text-chart-2 border-chart-2/20",
    label: "日记",
  },
  todo: {
    icon: CheckSquare,
    color: "bg-accent/10 text-accent border-accent/20",
    label: "待办",
  },
  goal: {
    icon: Target,
    color: "bg-chart-1/10 text-chart-1 border-chart-1/20",
    label: "目标",
  },
  weight: {
    icon: Scale,
    color: "bg-chart-5/10 text-chart-5 border-chart-5/20",
    label: "体重",
  },
}

export function EventCard({ event, onClick }: EventCardProps) {
  const config = eventConfig[event.type]
  const Icon = config.icon

  return (
    <button
      onClick={onClick}
      className={cn(
        "flex w-full items-start gap-3 rounded-xl border p-3 text-left transition-opacity hover:opacity-80 active:opacity-60",
        config.color
      )}
    >
      <div className="mt-0.5 rounded-lg bg-background/50 p-2">
        <Icon className="h-4 w-4" />
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className="text-xs font-medium opacity-70">{config.label}</span>
          {event.time && (
            <span className="text-xs opacity-60">{event.time}</span>
          )}
        </div>
        <p className="mt-0.5 font-medium text-foreground">{event.title}</p>
        {event.description && (
          <p className="mt-1 text-sm opacity-70">{event.description}</p>
        )}
      </div>
      <ChevronRight className="mt-1 h-4 w-4 shrink-0 opacity-40" />
    </button>
  )
}
