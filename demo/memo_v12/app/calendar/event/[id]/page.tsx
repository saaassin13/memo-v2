"use client"

import { useState, use } from "react"
import { useRouter } from "next/navigation"
import { MobileLayout } from "@/components/mobile-layout"
import {
  ArrowLeft,
  FileText,
  BookOpen,
  CheckSquare,
  Target,
  Scale,
  Trash2,
  Clock,
  Calendar,
  Save,
} from "lucide-react"
import { cn } from "@/lib/utils"
import type { CalendarEvent, EventType } from "@/app/calendar/page"

// 模拟事件数据（与 calendar/page.tsx 保持一致）
const mockEvents: CalendarEvent[] = [
  {
    id: "1",
    title: "完成项目报告",
    type: "todo",
    date: "2026-03-19",
    time: "14:00",
    description: "需要整理本季度的项目总结报告，包括进度、问题和下一步计划。",
  },
  {
    id: "2",
    title: "今天心情不错",
    type: "diary",
    date: "2026-03-19",
    description: "春光明媚，工作顺利。下午去公园散步了一圈，感觉神清气爽。",
  },
  {
    id: "3",
    title: "会议备忘",
    type: "memo",
    date: "2026-03-19",
    time: "10:00",
    description: "周会内容：讨论 Q2 规划，确认各部门目标。",
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
    description: "《原则》第三章读完，记录要点：...",
  },
  {
    id: "7",
    title: "跑步计划",
    type: "goal",
    date: "2026-03-18",
    description: "进度 40%",
  },
]

const eventConfig: Record<
  EventType,
  { icon: React.ElementType; label: string; color: string; bg: string }
> = {
  memo: {
    icon: FileText,
    label: "备忘",
    color: "text-primary",
    bg: "bg-primary/10",
  },
  diary: {
    icon: BookOpen,
    label: "日记",
    color: "text-chart-2",
    bg: "bg-chart-2/10",
  },
  todo: {
    icon: CheckSquare,
    label: "待办",
    color: "text-accent",
    bg: "bg-accent/10",
  },
  goal: {
    icon: Target,
    label: "目标",
    color: "text-chart-1",
    bg: "bg-chart-1/10",
  },
  weight: {
    icon: Scale,
    label: "体重",
    color: "text-chart-5",
    bg: "bg-chart-5/10",
  },
}

export default function EventDetailPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = use(params)
  const router = useRouter()
  const event = mockEvents.find((e) => e.id === id)

  const [title, setTitle] = useState(event?.title ?? "")
  const [description, setDescription] = useState(event?.description ?? "")
  const [time, setTime] = useState(event?.time ?? "")
  const [date, setDate] = useState(event?.date ?? "")
  const [saved, setSaved] = useState(false)

  if (!event) {
    return (
      <MobileLayout>
        <div className="flex flex-col items-center justify-center h-full py-20 text-muted-foreground">
          <p className="text-sm">事件不存在</p>
          <button
            onClick={() => router.back()}
            className="mt-4 text-sm text-primary underline"
          >
            返回
          </button>
        </div>
      </MobileLayout>
    )
  }

  const config = eventConfig[event.type]
  const Icon = config.icon

  const handleSave = () => {
    // 实际项目中在此处保存数据
    setSaved(true)
    setTimeout(() => setSaved(false), 2000)
  }

  return (
    <MobileLayout>
      <div className="flex flex-col min-h-full">
        {/* 顶部导航 */}
        <header className="sticky top-0 z-40 flex items-center justify-between border-b border-border bg-card/95 px-4 py-3 backdrop-blur-md">
          <button
            onClick={() => router.back()}
            className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <div className="flex items-center gap-2">
            <div className={cn("rounded-lg p-1.5", config.bg)}>
              <Icon className={cn("h-4 w-4", config.color)} />
            </div>
            <span className="font-medium text-foreground">{config.label}详情</span>
          </div>
          <button
            onClick={() => {/* 删除逻辑 */ router.back()}}
            className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-destructive/10 hover:text-destructive"
          >
            <Trash2 className="h-5 w-5" />
          </button>
        </header>

        <div className="flex-1 p-4 space-y-4">
          {/* 类型标签 */}
          <div className={cn("inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-medium", config.bg, config.color)}>
            <Icon className="h-3.5 w-3.5" />
            {config.label}
          </div>

          {/* 标题 */}
          <div>
            <label className="mb-1.5 block text-xs font-medium text-muted-foreground">
              标题
            </label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full rounded-xl border border-border bg-secondary px-4 py-3 text-base font-medium text-foreground placeholder:text-muted-foreground focus:border-primary/50 focus:outline-none focus:ring-2 focus:ring-primary/20"
              placeholder="输入标题..."
            />
          </div>

          {/* 日期与时间 */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="mb-1.5 flex items-center gap-1 text-xs font-medium text-muted-foreground">
                <Calendar className="h-3.5 w-3.5" />
                日期
              </label>
              <input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                className="w-full rounded-xl border border-border bg-secondary px-3 py-2.5 text-sm text-foreground focus:border-primary/50 focus:outline-none focus:ring-2 focus:ring-primary/20"
              />
            </div>
            <div>
              <label className="mb-1.5 flex items-center gap-1 text-xs font-medium text-muted-foreground">
                <Clock className="h-3.5 w-3.5" />
                时间（可选）
              </label>
              <input
                type="time"
                value={time}
                onChange={(e) => setTime(e.target.value)}
                className="w-full rounded-xl border border-border bg-secondary px-3 py-2.5 text-sm text-foreground focus:border-primary/50 focus:outline-none focus:ring-2 focus:ring-primary/20"
              />
            </div>
          </div>

          {/* 内容 / 备注 */}
          <div>
            <label className="mb-1.5 block text-xs font-medium text-muted-foreground">
              {event.type === "diary" ? "日记内容" : event.type === "memo" ? "备忘内容" : "备注"}
            </label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              rows={6}
              className="w-full resize-none rounded-xl border border-border bg-secondary px-4 py-3 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary/50 focus:outline-none focus:ring-2 focus:ring-primary/20"
              placeholder="输入内容..."
            />
          </div>

          {/* 元信息 */}
          <div className="rounded-xl bg-secondary p-4 space-y-2">
            <h3 className="text-xs font-medium text-muted-foreground">信息</h3>
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">创建时间</span>
              <span className="text-foreground">
                {new Date(event.date).toLocaleDateString("zh-CN", {
                  year: "numeric",
                  month: "long",
                  day: "numeric",
                })}
              </span>
            </div>
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">类型</span>
              <span className={cn("font-medium", config.color)}>{config.label}</span>
            </div>
          </div>
        </div>

        {/* 底部保存按钮 */}
        <div className="sticky bottom-0 border-t border-border bg-card/95 p-4 backdrop-blur-md">
          <button
            onClick={handleSave}
            className={cn(
              "flex w-full items-center justify-center gap-2 rounded-xl py-3 text-sm font-medium transition-all",
              saved
                ? "bg-accent/20 text-accent"
                : "bg-primary text-primary-foreground hover:opacity-90 active:scale-[0.98]"
            )}
          >
            <Save className="h-4 w-4" />
            {saved ? "已保存" : "保存"}
          </button>
        </div>
      </div>
    </MobileLayout>
  )
}
