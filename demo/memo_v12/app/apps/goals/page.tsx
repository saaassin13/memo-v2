"use client"

import { useState } from "react"
import Link from "next/link"
import { ArrowLeft, Plus, Target, Calendar, MoreHorizontal, Trash2, Edit, CheckCircle2 } from "lucide-react"
import { cn } from "@/lib/utils"
import { Progress } from "@/components/ui/progress"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"

interface Goal {
  id: string
  name: string
  target: number
  current: number
  unit: string
  deadline?: string
}

const initialGoals: Goal[] = [
  {
    id: "1",
    name: "阅读 12 本书",
    target: 12,
    current: 5,
    unit: "本",
    deadline: "2026-12-31",
  },
  {
    id: "2",
    name: "跑步 100 公里",
    target: 100,
    current: 42,
    unit: "公里",
    deadline: "2026-06-30",
  },
  {
    id: "3",
    name: "存款 50000 元",
    target: 50000,
    current: 23000,
    unit: "元",
    deadline: "2026-12-31",
  },
  {
    id: "4",
    name: "学习 100 小时",
    target: 100,
    current: 100,
    unit: "小时",
  },
]

export default function GoalsPage() {
  const [goals, setGoals] = useState<Goal[]>(initialGoals)
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingGoal, setEditingGoal] = useState<Goal | null>(null)
  const [formData, setFormData] = useState({
    name: "",
    target: "",
    current: "",
    unit: "",
    deadline: "",
  })

  const deleteGoal = (id: string) => {
    setGoals((prev) => prev.filter((g) => g.id !== id))
  }

  const incrementProgress = (id: string) => {
    setGoals((prev) =>
      prev.map((g) =>
        g.id === id ? { ...g, current: Math.min(g.current + 1, g.target) } : g
      )
    )
  }

  const openAddDialog = () => {
    setEditingGoal(null)
    setFormData({ name: "", target: "", current: "", unit: "", deadline: "" })
    setDialogOpen(true)
  }

  const handleSave = () => {
    if (!formData.name.trim() || !formData.target) return
    if (editingGoal) {
      setGoals((prev) =>
        prev.map((g) =>
          g.id === editingGoal.id
            ? {
                ...g,
                name: formData.name,
                target: parseInt(formData.target),
                current: parseInt(formData.current) || 0,
                unit: formData.unit,
                deadline: formData.deadline || undefined,
              }
            : g
        )
      )
    } else {
      const newGoal: Goal = {
        id: Date.now().toString(),
        name: formData.name,
        target: parseInt(formData.target),
        current: parseInt(formData.current) || 0,
        unit: formData.unit,
        deadline: formData.deadline || undefined,
      }
      setGoals((prev) => [...prev, newGoal])
    }
    setDialogOpen(false)
  }

  const activeGoals = goals.filter((g) => g.current < g.target)
  const completedGoals = goals.filter((g) => g.current >= g.target)

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
          <h1 className="text-xl font-semibold text-foreground">目标</h1>
        </div>
        <button
          onClick={openAddDialog}
          className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
        >
          <Plus className="h-5 w-5" />
        </button>
      </header>

      <div className="flex-1 p-4">
        {activeGoals.length > 0 && (
          <div className="mb-6">
            <h2 className="mb-3 text-sm font-medium text-muted-foreground">
              进行中 ({activeGoals.length})
            </h2>
            <div className="space-y-3">
              {activeGoals.map((goal) => {
                const progress = Math.round((goal.current / goal.target) * 100)
                return (
                  <Link
                    key={goal.id}
                    href={`/apps/goals/${goal.id}`}
                    className="block rounded-xl bg-card p-4 shadow-sm transition-colors hover:bg-card/80"
                  >
                    <div className="mb-3 flex items-start justify-between">
                      <div className="flex items-center gap-3">
                        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
                          <Target className="h-5 w-5" />
                        </div>
                        <div>
                          <h3 className="font-medium text-foreground">
                            {goal.name}
                          </h3>
                          {goal.deadline && (
                            <div className="mt-0.5 flex items-center gap-1 text-xs text-muted-foreground">
                              <Calendar className="h-3 w-3" />
                              截止 {goal.deadline}
                            </div>
                          )}
                        </div>
                      </div>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <button
                            onClick={(e) => e.preventDefault()}
                            className="rounded-full p-1 text-muted-foreground hover:bg-secondary hover:text-foreground"
                          >
                            <MoreHorizontal className="h-4 w-4" />
                          </button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem
                            onClick={(e) => {
                              e.preventDefault()
                              setEditingGoal(goal)
                              setFormData({
                                name: goal.name,
                                target: goal.target.toString(),
                                current: goal.current.toString(),
                                unit: goal.unit,
                                deadline: goal.deadline || "",
                              })
                              setDialogOpen(true)
                            }}
                          >
                            <Edit className="mr-2 h-4 w-4" />
                            编辑
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            onClick={(e) => {
                              e.preventDefault()
                              deleteGoal(goal.id)
                            }}
                            className="text-destructive focus:text-destructive"
                          >
                            <Trash2 className="mr-2 h-4 w-4" />
                            删除
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </div>
                    <div className="flex items-center gap-3">
                      <Progress value={progress} className="flex-1" />
                      <span className="text-sm font-medium text-foreground">
                        {goal.current}/{goal.target} {goal.unit}
                      </span>
                      <button
                        onClick={(e) => {
                          e.preventDefault()
                          incrementProgress(goal.id)
                        }}
                        className="rounded-full bg-primary/10 p-1.5 text-primary transition-colors hover:bg-primary/20"
                      >
                        <Plus className="h-4 w-4" />
                      </button>
                    </div>
                  </Link>
                )
              })}
            </div>
          </div>
        )}

        {completedGoals.length > 0 && (
          <div>
            <h2 className="mb-3 text-sm font-medium text-muted-foreground">
              已完成 ({completedGoals.length})
            </h2>
            <div className="space-y-3">
              {completedGoals.map((goal) => (
                <Link
                  key={goal.id}
                  href={`/apps/goals/${goal.id}`}
                  className="flex items-center gap-3 rounded-xl bg-card p-4 shadow-sm transition-colors hover:bg-card/80"
                >
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-accent/10 text-accent">
                    <CheckCircle2 className="h-5 w-5" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-medium text-muted-foreground line-through">
                      {goal.name}
                    </h3>
                    <p className="text-xs text-muted-foreground">
                      {goal.target} {goal.unit}
                    </p>
                  </div>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <button
                        onClick={(e) => e.preventDefault()}
                        className="rounded-full p-1 text-muted-foreground hover:bg-secondary hover:text-foreground"
                      >
                        <MoreHorizontal className="h-4 w-4" />
                      </button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuItem
                        onClick={(e) => {
                          e.preventDefault()
                          deleteGoal(goal.id)
                        }}
                        className="text-destructive focus:text-destructive"
                      >
                        <Trash2 className="mr-2 h-4 w-4" />
                        删除
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </Link>
              ))}
            </div>
          </div>
        )}
      </div>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-[calc(100vw-2rem)] rounded-2xl sm:max-w-md">
          <DialogHeader>
            <DialogTitle>{editingGoal ? "编辑目标" : "新建目标"}</DialogTitle>
            <DialogDescription>
              {editingGoal ? "修改目标详情" : "设定一个新的目标"}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <Input
              placeholder="目标名称"
              value={formData.name}
              onChange={(e) =>
                setFormData((prev) => ({ ...prev, name: e.target.value }))
              }
            />
            <div className="grid grid-cols-2 gap-3">
              <Input
                type="number"
                placeholder="目标值"
                value={formData.target}
                onChange={(e) =>
                  setFormData((prev) => ({ ...prev, target: e.target.value }))
                }
              />
              <Input
                placeholder="单位"
                value={formData.unit}
                onChange={(e) =>
                  setFormData((prev) => ({ ...prev, unit: e.target.value }))
                }
              />
            </div>
            <Input
              type="number"
              placeholder="当前进度"
              value={formData.current}
              onChange={(e) =>
                setFormData((prev) => ({ ...prev, current: e.target.value }))
              }
            />
            <div>
              <label className="mb-2 block text-sm font-medium">截止日期（可选）</label>
              <Input
                type="date"
                value={formData.deadline}
                onChange={(e) =>
                  setFormData((prev) => ({ ...prev, deadline: e.target.value }))
                }
              />
            </div>
          </div>
          <div className="flex gap-3">
            <Button
              variant="outline"
              className="flex-1"
              onClick={() => setDialogOpen(false)}
            >
              取消
            </Button>
            <Button
              className="flex-1"
              onClick={handleSave}
              disabled={!formData.name.trim() || !formData.target}
            >
              保存
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
