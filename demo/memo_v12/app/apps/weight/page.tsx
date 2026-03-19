"use client"

import { useState } from "react"
import Link from "next/link"
import { ArrowLeft, LineChart, Plus, TrendingDown, TrendingUp, Minus, List, CalendarDays, Dumbbell, Sofa, ChevronDown, ChevronRight } from "lucide-react"
import { cn } from "@/lib/utils"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import {
  LineChart as RechartsLineChart,
  Line,
  XAxis,
  YAxis,
  ResponsiveContainer,
  Tooltip,
} from "recharts"

interface WeightRecord {
  id: string
  weight: number
  date: string
  exercised: boolean
  note: string
}

type ViewMode = "list" | "month"

const initialRecords: WeightRecord[] = [
  { id: "1", weight: 68.5, date: "2026-03-18", exercised: true, note: "晨跑5公里" },
  { id: "2", weight: 68.8, date: "2026-03-17", exercised: false, note: "" },
  { id: "3", weight: 69.0, date: "2026-03-16", exercised: true, note: "健身房力量训练" },
  { id: "4", weight: 68.7, date: "2026-03-15", exercised: true, note: "游泳1小时" },
  { id: "5", weight: 69.2, date: "2026-03-14", exercised: false, note: "今天休息" },
  { id: "6", weight: 69.5, date: "2026-03-13", exercised: false, note: "" },
  { id: "7", weight: 69.8, date: "2026-03-12", exercised: true, note: "瑜伽课程" },
  { id: "8", weight: 70.0, date: "2026-03-05", exercised: true, note: "" },
  { id: "9", weight: 70.2, date: "2026-03-01", exercised: false, note: "" },
  { id: "10", weight: 70.5, date: "2026-02-28", exercised: true, note: "" },
  { id: "11", weight: 70.3, date: "2026-02-25", exercised: false, note: "" },
  { id: "12", weight: 70.8, date: "2026-02-20", exercised: true, note: "" },
]

export default function WeightPage() {
  const [records, setRecords] = useState<WeightRecord[]>(initialRecords)
  const [dialogOpen, setDialogOpen] = useState(false)
  const [newWeight, setNewWeight] = useState("")
  const [newExercised, setNewExercised] = useState(false)
  const [newNote, setNewNote] = useState("")
  const [showChart, setShowChart] = useState(false)
  const [viewMode, setViewMode] = useState<ViewMode>("list")
  const [expandedMonths, setExpandedMonths] = useState<string[]>([])

  const latestWeight = records[0]?.weight || 0
  const previousWeight = records[1]?.weight || latestWeight
  const weightDiff = latestWeight - previousWeight
  const trend = weightDiff === 0 ? "same" : weightDiff < 0 ? "down" : "up"

  const chartData = [...records]
    .slice(0, 7)
    .reverse()
    .map((r) => ({
      date: r.date.slice(5),
      weight: r.weight,
    }))

  // Get last 7 days records for list view
  const lastWeekRecords = records.slice(0, 7)

  // Group records by month for month view
  const recordsByMonth = records.reduce((acc, record) => {
    const monthKey = record.date.slice(0, 7) // "2026-03"
    if (!acc[monthKey]) {
      acc[monthKey] = []
    }
    acc[monthKey].push(record)
    return acc
  }, {} as Record<string, WeightRecord[]>)

  const sortedMonths = Object.keys(recordsByMonth).sort((a, b) => b.localeCompare(a))

  const toggleMonth = (month: string) => {
    setExpandedMonths(prev => 
      prev.includes(month) 
        ? prev.filter(m => m !== month)
        : [...prev, month]
    )
  }

  const formatMonth = (monthKey: string) => {
    const [year, month] = monthKey.split("-")
    return `${year}年${parseInt(month)}月`
  }

  const handleSave = () => {
    if (!newWeight) return
    const newRecord: WeightRecord = {
      id: Date.now().toString(),
      weight: parseFloat(newWeight),
      date: new Date().toISOString().split("T")[0],
      exercised: newExercised,
      note: newNote,
    }
    setRecords((prev) => [newRecord, ...prev])
    setDialogOpen(false)
    setNewWeight("")
    setNewExercised(false)
    setNewNote("")
  }

  const renderRecordItem = (record: WeightRecord, index: number, recordsList: WeightRecord[]) => {
    const prevRecord = recordsList[index + 1]
    const diff = prevRecord ? record.weight - prevRecord.weight : 0
    return (
      <div
        key={record.id}
        className="flex items-center justify-between rounded-xl bg-card p-4 shadow-sm"
      >
        <div className="flex items-center gap-3">
          <div className={cn(
            "flex h-8 w-8 items-center justify-center rounded-full",
            record.exercised 
              ? "bg-accent/10 text-accent" 
              : "bg-muted text-muted-foreground"
          )}>
            {record.exercised ? (
              <Dumbbell className="h-4 w-4" />
            ) : (
              <Sofa className="h-4 w-4" />
            )}
          </div>
          <div>
            <span className="text-sm text-muted-foreground">
              {record.date}
            </span>
            {record.note && (
              <p className="text-xs text-muted-foreground/70 mt-0.5 max-w-[120px] truncate">
                {record.note}
              </p>
            )}
          </div>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-lg font-semibold text-foreground">
            {record.weight.toFixed(1)} kg
          </span>
          {prevRecord && (
            <span
              className={cn(
                "text-sm min-w-[48px] text-right",
                diff < 0
                  ? "text-accent"
                  : diff > 0
                    ? "text-destructive"
                    : "text-muted-foreground"
              )}
            >
              {diff > 0 ? "+" : ""}
              {diff.toFixed(1)}
            </span>
          )}
        </div>
      </div>
    )
  }

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
          <h1 className="text-xl font-semibold text-foreground">体重</h1>
        </div>
        <button
          onClick={() => setShowChart(!showChart)}
          className={cn(
            "rounded-full p-2 transition-colors",
            showChart
              ? "bg-primary/10 text-primary"
              : "text-muted-foreground hover:bg-secondary hover:text-foreground"
          )}
        >
          <LineChart className="h-5 w-5" />
        </button>
      </header>

      <div className="bg-card p-6">
        <div className="text-center">
          <p className="text-sm text-muted-foreground">今日体重</p>
          <div className="mt-2 flex items-center justify-center gap-2">
            <span className="text-5xl font-bold text-foreground">
              {latestWeight.toFixed(1)}
            </span>
            <span className="text-xl text-muted-foreground">kg</span>
          </div>
          <div
            className={cn(
              "mt-2 inline-flex items-center gap-1 rounded-full px-3 py-1 text-sm font-medium",
              trend === "down"
                ? "bg-accent/10 text-accent"
                : trend === "up"
                  ? "bg-destructive/10 text-destructive"
                  : "bg-muted text-muted-foreground"
            )}
          >
            {trend === "down" ? (
              <TrendingDown className="h-4 w-4" />
            ) : trend === "up" ? (
              <TrendingUp className="h-4 w-4" />
            ) : (
              <Minus className="h-4 w-4" />
            )}
            {weightDiff === 0
              ? "持平"
              : `${weightDiff > 0 ? "+" : ""}${weightDiff.toFixed(1)} kg`}
          </div>
        </div>
      </div>

      {showChart && (
        <div className="border-b border-border bg-card p-4">
          <h3 className="mb-3 text-sm font-medium text-muted-foreground">
            体重趋势
          </h3>
          <div className="h-48">
            <ResponsiveContainer width="100%" height="100%">
              <RechartsLineChart data={chartData}>
                <XAxis
                  dataKey="date"
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: "var(--muted-foreground)", fontSize: 12 }}
                />
                <YAxis
                  domain={["dataMin - 1", "dataMax + 1"]}
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: "var(--muted-foreground)", fontSize: 12 }}
                  width={40}
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "var(--card)",
                    border: "1px solid var(--border)",
                    borderRadius: "8px",
                  }}
                />
                <Line
                  type="monotone"
                  dataKey="weight"
                  stroke="var(--primary)"
                  strokeWidth={2}
                  dot={{ fill: "var(--primary)", strokeWidth: 0, r: 4 }}
                  activeDot={{ r: 6, strokeWidth: 0 }}
                />
              </RechartsLineChart>
            </ResponsiveContainer>
          </div>
        </div>
      )}

      <div className="flex-1 p-4">
        <div className="mb-3 flex items-center justify-between">
          <h3 className="text-sm font-medium text-muted-foreground">
            历史记录
          </h3>
          <div className="flex items-center gap-1 rounded-lg bg-secondary p-1">
            <button
              onClick={() => setViewMode("list")}
              className={cn(
                "flex items-center gap-1.5 rounded-md px-3 py-1.5 text-sm font-medium transition-colors",
                viewMode === "list"
                  ? "bg-card text-foreground shadow-sm"
                  : "text-muted-foreground hover:text-foreground"
              )}
            >
              <List className="h-4 w-4" />
              列表
            </button>
            <button
              onClick={() => setViewMode("month")}
              className={cn(
                "flex items-center gap-1.5 rounded-md px-3 py-1.5 text-sm font-medium transition-colors",
                viewMode === "month"
                  ? "bg-card text-foreground shadow-sm"
                  : "text-muted-foreground hover:text-foreground"
              )}
            >
              <CalendarDays className="h-4 w-4" />
              月
            </button>
          </div>
        </div>

        {viewMode === "list" ? (
          <div className="space-y-2">
            {lastWeekRecords.map((record, index) => 
              renderRecordItem(record, index, lastWeekRecords)
            )}
          </div>
        ) : (
          <div className="space-y-3">
            {sortedMonths.map((monthKey) => {
              const monthRecords = recordsByMonth[monthKey]
              const isExpanded = expandedMonths.includes(monthKey)
              const avgWeight = monthRecords.reduce((sum, r) => sum + r.weight, 0) / monthRecords.length
              const exerciseDays = monthRecords.filter(r => r.exercised).length
              
              return (
                <div key={monthKey} className="rounded-xl bg-card shadow-sm overflow-hidden">
                  <button
                    onClick={() => toggleMonth(monthKey)}
                    className="flex w-full items-center justify-between p-4 transition-colors hover:bg-secondary/50"
                  >
                    <div className="flex items-center gap-3">
                      {isExpanded ? (
                        <ChevronDown className="h-5 w-5 text-muted-foreground" />
                      ) : (
                        <ChevronRight className="h-5 w-5 text-muted-foreground" />
                      )}
                      <div className="text-left">
                        <span className="font-medium text-foreground">
                          {formatMonth(monthKey)}
                        </span>
                        <p className="text-xs text-muted-foreground mt-0.5">
                          {monthRecords.length} 条记录 · 运动 {exerciseDays} 天
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <span className="text-lg font-semibold text-foreground">
                        {avgWeight.toFixed(1)} kg
                      </span>
                      <p className="text-xs text-muted-foreground">平均</p>
                    </div>
                  </button>
                  
                  {isExpanded && (
                    <div className="border-t border-border p-3 space-y-2">
                      {monthRecords.map((record, index) => 
                        renderRecordItem(record, index, monthRecords)
                      )}
                    </div>
                  )}
                </div>
              )
            })}
          </div>
        )}
      </div>

      <button
        onClick={() => setDialogOpen(true)}
        className="fixed bottom-6 right-4 z-40 flex h-14 w-14 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg transition-transform hover:scale-105 active:scale-95"
      >
        <Plus className="h-6 w-6" />
      </button>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-[calc(100vw-2rem)] rounded-2xl sm:max-w-md">
          <DialogHeader>
            <DialogTitle>记录体重</DialogTitle>
            <DialogDescription>输入今日体重数据</DialogDescription>
          </DialogHeader>
          <div className="space-y-6 py-4">
            <div className="flex items-center justify-center gap-2">
              <Input
                type="number"
                step="0.1"
                placeholder="0.0"
                value={newWeight}
                onChange={(e) => setNewWeight(e.target.value)}
                className="w-32 text-center text-3xl font-bold"
              />
              <span className="text-xl text-muted-foreground">kg</span>
            </div>

            <div>
              <p className="text-sm font-medium text-foreground mb-3">今日运动</p>
              <div className="flex gap-3">
                <button
                  onClick={() => setNewExercised(true)}
                  className={cn(
                    "flex flex-1 flex-col items-center gap-2 rounded-xl border-2 p-4 transition-colors",
                    newExercised
                      ? "border-accent bg-accent/5"
                      : "border-border hover:border-accent/50"
                  )}
                >
                  <Dumbbell className={cn("h-6 w-6", newExercised ? "text-accent" : "text-muted-foreground")} />
                  <span className={cn("text-sm font-medium", newExercised ? "text-accent" : "text-foreground")}>运动了</span>
                </button>
                <button
                  onClick={() => setNewExercised(false)}
                  className={cn(
                    "flex flex-1 flex-col items-center gap-2 rounded-xl border-2 p-4 transition-colors",
                    !newExercised
                      ? "border-muted-foreground bg-muted/5"
                      : "border-border hover:border-muted-foreground/50"
                  )}
                >
                  <Sofa className={cn("h-6 w-6", !newExercised ? "text-muted-foreground" : "text-muted-foreground")} />
                  <span className={cn("text-sm font-medium", !newExercised ? "text-muted-foreground" : "text-foreground")}>休息日</span>
                </button>
              </div>
            </div>

            <div>
              <p className="text-sm font-medium text-foreground mb-2">备注</p>
              <Textarea
                placeholder="记录一些备注..."
                value={newNote}
                onChange={(e) => setNewNote(e.target.value)}
                className="resize-none"
                rows={2}
              />
            </div>
          </div>
          <div className="flex gap-3">
            <Button
              variant="outline"
              className="flex-1"
              onClick={() => {
                setDialogOpen(false)
                setNewWeight("")
                setNewExercised(false)
                setNewNote("")
              }}
            >
              取消
            </Button>
            <Button className="flex-1" onClick={handleSave} disabled={!newWeight}>
              保存
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
