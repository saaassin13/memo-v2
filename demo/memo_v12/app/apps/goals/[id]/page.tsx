"use client"

import { useState, useEffect } from "react"
import { useParams, useRouter } from "next/navigation"
import Link from "next/link"
import {
  ArrowLeft,
  Plus,
  Target,
  Calendar,
  Edit,
  Trash2,
  History,
  FileText,
  TrendingUp,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { Progress } from "@/components/ui/progress"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"

interface ProgressRecord {
  id: string
  amount: number
  note?: string
  createdAt: string
}

interface Goal {
  id: string
  name: string
  target: number
  current: number
  unit: string
  deadline?: string
  note?: string
  records: ProgressRecord[]
}

const mockGoals: Goal[] = [
  {
    id: "1",
    name: "阅读 12 本书",
    target: 12,
    current: 5,
    unit: "本",
    deadline: "2026-12-31",
    note: "今年计划阅读更多关于技术和个人成长的书籍",
    records: [
      { id: "r1", amount: 2, note: "完成《深度工作》和《原子习惯》", createdAt: "2026-01-15" },
      { id: "r2", amount: 1, note: "完成《思考快与慢》", createdAt: "2026-02-10" },
      { id: "r3", amount: 2, note: "完成两本技术书籍", createdAt: "2026-03-05" },
    ],
  },
  {
    id: "2",
    name: "跑步 100 公里",
    target: 100,
    current: 42,
    unit: "公里",
    deadline: "2026-06-30",
    note: "保持每周跑步习惯，逐步提升体能",
    records: [
      { id: "r4", amount: 15, note: "一月份跑步", createdAt: "2026-01-31" },
      { id: "r5", amount: 12, note: "二月份跑步", createdAt: "2026-02-28" },
      { id: "r6", amount: 15, note: "三月份跑步", createdAt: "2026-03-15" },
    ],
  },
  {
    id: "3",
    name: "存款 50000 元",
    target: 50000,
    current: 23000,
    unit: "元",
    deadline: "2026-12-31",
    note: "每月固定存款，减少不必要开支",
    records: [
      { id: "r7", amount: 8000, note: "一月存款", createdAt: "2026-01-31" },
      { id: "r8", amount: 7500, note: "二月存款", createdAt: "2026-02-28" },
      { id: "r9", amount: 7500, note: "三月存款", createdAt: "2026-03-15" },
    ],
  },
  {
    id: "4",
    name: "学习 100 小时",
    target: 100,
    current: 100,
    unit: "小时",
    note: "完成在线课程学习目标",
    records: [
      { id: "r10", amount: 35, note: "React 进阶课程", createdAt: "2026-01-20" },
      { id: "r11", amount: 30, note: "TypeScript 深入学习", createdAt: "2026-02-15" },
      { id: "r12", amount: 35, note: "Node.js 后端开发", createdAt: "2026-03-10" },
    ],
  },
]

export default function GoalDetailPage() {
  const params = useParams()
  const router = useRouter()
  const [goal, setGoal] = useState<Goal | null>(null)
  const [progressDialogOpen, setProgressDialogOpen] = useState(false)
  const [editNoteDialogOpen, setEditNoteDialogOpen] = useState(false)
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
  const [progressForm, setProgressForm] = useState({ amount: "", note: "" })
  const [noteForm, setNoteForm] = useState("")

  useEffect(() => {
    const foundGoal = mockGoals.find((g) => g.id === params.id)
    if (foundGoal) {
      setGoal(foundGoal)
      setNoteForm(foundGoal.note || "")
    }
  }, [params.id])

  if (!goal) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <p className="text-muted-foreground">目标不存在</p>
      </div>
    )
  }

  const progress = Math.round((goal.current / goal.target) * 100)
  const isCompleted = goal.current >= goal.target

  const handleAddProgress = () => {
    if (!progressForm.amount) return
    const amount = parseFloat(progressForm.amount)
    if (isNaN(amount) || amount <= 0) return

    const newRecord: ProgressRecord = {
      id: Date.now().toString(),
      amount,
      note: progressForm.note || undefined,
      createdAt: new Date().toISOString().split("T")[0],
    }

    setGoal((prev) => {
      if (!prev) return prev
      return {
        ...prev,
        current: Math.min(prev.current + amount, prev.target),
        records: [newRecord, ...prev.records],
      }
    })
    setProgressForm({ amount: "", note: "" })
    setProgressDialogOpen(false)
  }

  const handleSaveNote = () => {
    setGoal((prev) => {
      if (!prev) return prev
      return { ...prev, note: noteForm }
    })
    setEditNoteDialogOpen(false)
  }

  const handleDelete = () => {
    router.push("/apps/goals")
  }

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr)
    return date.toLocaleDateString("zh-CN", {
      year: "numeric",
      month: "long",
      day: "numeric",
    })
  }

  return (
    <div className="flex min-h-screen flex-col bg-background">
      <header className="sticky top-0 z-40 flex items-center justify-between border-b border-border bg-card/95 px-4 py-3 backdrop-blur-md">
        <div className="flex items-center gap-3">
          <Link
            href="/apps/goals"
            className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
          >
            <ArrowLeft className="h-5 w-5" />
          </Link>
          <h1 className="text-xl font-semibold text-foreground">目标详情</h1>
        </div>
        <button
          onClick={() => setDeleteDialogOpen(true)}
          className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-destructive"
        >
          <Trash2 className="h-5 w-5" />
        </button>
      </header>

      <div className="flex-1 space-y-4 p-4">
        {/* 目标信息卡片 */}
        <div className="rounded-xl bg-card p-5 shadow-sm">
          <div className="mb-4 flex items-start gap-4">
            <div
              className={cn(
                "flex h-14 w-14 items-center justify-center rounded-2xl",
                isCompleted ? "bg-accent/10 text-accent" : "bg-primary/10 text-primary"
              )}
            >
              <Target className="h-7 w-7" />
            </div>
            <div className="flex-1 min-w-0">
              <h2 className="text-lg font-semibold text-foreground">{goal.name}</h2>
              {goal.deadline && (
                <div className="mt-1 flex items-center gap-1.5 text-sm text-muted-foreground">
                  <Calendar className="h-4 w-4" />
                  截止 {formatDate(goal.deadline)}
                </div>
              )}
            </div>
          </div>

          <div className="mb-4">
            <div className="mb-2 flex items-center justify-between text-sm">
              <span className="text-muted-foreground">完成进度</span>
              <span className="font-medium text-foreground">{progress}%</span>
            </div>
            <Progress value={progress} className="h-3" />
            <div className="mt-2 text-center">
              <span className="text-2xl font-bold text-foreground">{goal.current}</span>
              <span className="text-muted-foreground">
                {" "}
                / {goal.target} {goal.unit}
              </span>
            </div>
          </div>

          {!isCompleted && (
            <Button className="w-full" onClick={() => setProgressDialogOpen(true)}>
              <Plus className="mr-2 h-4 w-4" />
              添加进度
            </Button>
          )}

          {isCompleted && (
            <div className="rounded-lg bg-accent/10 p-3 text-center text-sm font-medium text-accent">
              目标已完成
            </div>
          )}
        </div>

        {/* 备注卡片 */}
        <div className="rounded-xl bg-card p-4 shadow-sm">
          <div className="mb-3 flex items-center justify-between">
            <div className="flex items-center gap-2 text-sm font-medium text-foreground">
              <FileText className="h-4 w-4 text-muted-foreground" />
              备注
            </div>
            <button
              onClick={() => setEditNoteDialogOpen(true)}
              className="rounded-full p-1.5 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
            >
              <Edit className="h-4 w-4" />
            </button>
          </div>
          {goal.note ? (
            <p className="text-sm leading-relaxed text-muted-foreground">{goal.note}</p>
          ) : (
            <p className="text-sm text-muted-foreground/60">暂无备注，点击编辑添加</p>
          )}
        </div>

        {/* 历史记录 */}
        <div className="rounded-xl bg-card p-4 shadow-sm">
          <div className="mb-4 flex items-center gap-2 text-sm font-medium text-foreground">
            <History className="h-4 w-4 text-muted-foreground" />
            完成记录
            <span className="ml-auto text-muted-foreground">
              共 {goal.records.length} 条
            </span>
          </div>

          {goal.records.length > 0 ? (
            <div className="space-y-3">
              {goal.records.map((record) => (
                <div
                  key={record.id}
                  className="flex items-start gap-3 rounded-lg bg-secondary/50 p-3"
                >
                  <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/10">
                    <TrendingUp className="h-4 w-4 text-primary" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <span className="font-medium text-foreground">
                        +{record.amount} {goal.unit}
                      </span>
                      <span className="text-xs text-muted-foreground">
                        {formatDate(record.createdAt)}
                      </span>
                    </div>
                    {record.note && (
                      <p className="mt-1 text-sm text-muted-foreground">{record.note}</p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="py-8 text-center text-sm text-muted-foreground">
              暂无完成记录
            </div>
          )}
        </div>
      </div>

      {/* 添加进度对话框 */}
      <Dialog open={progressDialogOpen} onOpenChange={setProgressDialogOpen}>
        <DialogContent className="max-w-[calc(100vw-2rem)] rounded-2xl sm:max-w-md">
          <DialogHeader>
            <DialogTitle>添加进度</DialogTitle>
            <DialogDescription>记录你的进度更新</DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div>
              <label className="mb-2 block text-sm font-medium">
                增加数量 ({goal.unit})
              </label>
              <Input
                type="number"
                placeholder={`输入 ${goal.unit} 数`}
                value={progressForm.amount}
                onChange={(e) =>
                  setProgressForm((prev) => ({ ...prev, amount: e.target.value }))
                }
              />
            </div>
            <div>
              <label className="mb-2 block text-sm font-medium">备注（可选）</label>
              <Textarea
                placeholder="添加备注说明"
                value={progressForm.note}
                onChange={(e) =>
                  setProgressForm((prev) => ({ ...prev, note: e.target.value }))
                }
                rows={3}
              />
            </div>
          </div>
          <div className="flex gap-3">
            <Button
              variant="outline"
              className="flex-1"
              onClick={() => setProgressDialogOpen(false)}
            >
              取消
            </Button>
            <Button
              className="flex-1"
              onClick={handleAddProgress}
              disabled={!progressForm.amount}
            >
              保存
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* 编辑备注对话框 */}
      <Dialog open={editNoteDialogOpen} onOpenChange={setEditNoteDialogOpen}>
        <DialogContent className="max-w-[calc(100vw-2rem)] rounded-2xl sm:max-w-md">
          <DialogHeader>
            <DialogTitle>编辑备注</DialogTitle>
            <DialogDescription>添加或修改目标备注</DialogDescription>
          </DialogHeader>
          <div className="py-4">
            <Textarea
              placeholder="输入目标备注..."
              value={noteForm}
              onChange={(e) => setNoteForm(e.target.value)}
              rows={5}
            />
          </div>
          <div className="flex gap-3">
            <Button
              variant="outline"
              className="flex-1"
              onClick={() => setEditNoteDialogOpen(false)}
            >
              取消
            </Button>
            <Button className="flex-1" onClick={handleSaveNote}>
              保存
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* 删除确认对话框 */}
      <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
        <AlertDialogContent className="max-w-[calc(100vw-2rem)] rounded-2xl sm:max-w-md">
          <AlertDialogHeader>
            <AlertDialogTitle>确认删除</AlertDialogTitle>
            <AlertDialogDescription>
              确定要删除目标"{goal.name}"吗？此操作无法撤销。
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>取消</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleDelete}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              删除
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
