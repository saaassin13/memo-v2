"use client"

import { useState } from "react"
import Link from "next/link"
import { ArrowLeft, Plus, Gift, Star, Heart, Calendar, MoreHorizontal, Trash2, Edit } from "lucide-react"
import { cn } from "@/lib/utils"
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

interface Countdown {
  id: string
  name: string
  date: string
  category: "birthday" | "holiday" | "important"
  repeat: boolean
}

const initialCountdowns: Countdown[] = [
  {
    id: "1",
    name: "妈妈生日",
    date: "2026-04-15",
    category: "birthday",
    repeat: true,
  },
  {
    id: "2",
    name: "结婚纪念日",
    date: "2026-05-20",
    category: "important",
    repeat: true,
  },
  {
    id: "3",
    name: "端午节",
    date: "2026-05-31",
    category: "holiday",
    repeat: true,
  },
  {
    id: "4",
    name: "年度旅行",
    date: "2026-07-01",
    category: "important",
    repeat: false,
  },
]

const categoryConfig = {
  birthday: { icon: Gift, color: "bg-chart-4/10 text-chart-4", label: "生日" },
  holiday: { icon: Star, color: "bg-chart-3/10 text-chart-3", label: "节日" },
  important: { icon: Heart, color: "bg-primary/10 text-primary", label: "重要日" },
}

function calculateDays(targetDate: string): number {
  const target = new Date(targetDate)
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  target.setHours(0, 0, 0, 0)
  const diff = target.getTime() - today.getTime()
  return Math.ceil(diff / (1000 * 60 * 60 * 24))
}

export default function CountdownPage() {
  const [countdowns, setCountdowns] = useState<Countdown[]>(initialCountdowns)
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingItem, setEditingItem] = useState<Countdown | null>(null)
  const [formData, setFormData] = useState({
    name: "",
    date: "",
    category: "important" as const,
  })

  const sortedCountdowns = [...countdowns].sort((a, b) => {
    const daysA = calculateDays(a.date)
    const daysB = calculateDays(b.date)
    return daysA - daysB
  })

  const deleteCountdown = (id: string) => {
    setCountdowns((prev) => prev.filter((c) => c.id !== id))
  }

  const openAddDialog = () => {
    setEditingItem(null)
    setFormData({ name: "", date: "", category: "important" })
    setDialogOpen(true)
  }

  const handleSave = () => {
    if (!formData.name.trim() || !formData.date) return
    if (editingItem) {
      setCountdowns((prev) =>
        prev.map((c) =>
          c.id === editingItem.id
            ? { ...c, name: formData.name, date: formData.date, category: formData.category }
            : c
        )
      )
    } else {
      const newItem: Countdown = {
        id: Date.now().toString(),
        name: formData.name,
        date: formData.date,
        category: formData.category,
        repeat: false,
      }
      setCountdowns((prev) => [...prev, newItem])
    }
    setDialogOpen(false)
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
          <h1 className="text-xl font-semibold text-foreground">倒数纪念日</h1>
        </div>
        <button
          onClick={openAddDialog}
          className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
        >
          <Plus className="h-5 w-5" />
        </button>
      </header>

      <div className="flex-1 p-4">
        <div className="space-y-3">
          {sortedCountdowns.map((item) => {
            const days = calculateDays(item.date)
            const config = categoryConfig[item.category]
            const Icon = config.icon
            const isPast = days < 0
            const isToday = days === 0

            return (
              <div
                key={item.id}
                className="flex items-center gap-4 rounded-xl bg-card p-4 shadow-sm"
              >
                <div
                  className={cn(
                    "flex h-12 w-12 items-center justify-center rounded-xl",
                    config.color
                  )}
                >
                  <Icon className="h-6 w-6" />
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-medium text-foreground">{item.name}</h3>
                  <div className="mt-1 flex items-center gap-2">
                    <Calendar className="h-3 w-3 text-muted-foreground" />
                    <span className="text-xs text-muted-foreground">
                      {item.date}
                    </span>
                  </div>
                </div>
                <div className="text-right">
                  <span
                    className={cn(
                      "text-2xl font-bold",
                      isPast
                        ? "text-muted-foreground"
                        : isToday
                          ? "text-accent"
                          : "text-primary"
                    )}
                  >
                    {isToday ? "今天" : isPast ? `已过 ${Math.abs(days)}` : days}
                  </span>
                  {!isToday && (
                    <span className="ml-1 text-sm text-muted-foreground">天</span>
                  )}
                </div>
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <button className="rounded-full p-1 text-muted-foreground hover:bg-secondary hover:text-foreground">
                      <MoreHorizontal className="h-4 w-4" />
                    </button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    <DropdownMenuItem
                      onClick={() => {
                        setEditingItem(item)
                        setFormData({
                          name: item.name,
                          date: item.date,
                          category: item.category,
                        })
                        setDialogOpen(true)
                      }}
                    >
                      <Edit className="mr-2 h-4 w-4" />
                      编辑
                    </DropdownMenuItem>
                    <DropdownMenuItem
                      onClick={() => deleteCountdown(item.id)}
                      className="text-destructive focus:text-destructive"
                    >
                      <Trash2 className="mr-2 h-4 w-4" />
                      删除
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>
            )
          })}
        </div>
      </div>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-[calc(100vw-2rem)] rounded-2xl sm:max-w-md">
          <DialogHeader>
            <DialogTitle>{editingItem ? "编辑纪念日" : "新建纪念日"}</DialogTitle>
            <DialogDescription>
              {editingItem ? "修改纪念日信息" : "添加一个重要的日期"}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div>
              <Input
                placeholder="名称"
                value={formData.name}
                onChange={(e) =>
                  setFormData((prev) => ({ ...prev, name: e.target.value }))
                }
              />
            </div>
            <div>
              <Input
                type="date"
                value={formData.date}
                onChange={(e) =>
                  setFormData((prev) => ({ ...prev, date: e.target.value }))
                }
              />
            </div>
            <div>
              <label className="mb-2 block text-sm font-medium">分类</label>
              <div className="flex gap-2">
                {(Object.keys(categoryConfig) as Array<keyof typeof categoryConfig>).map(
                  (cat) => (
                    <button
                      key={cat}
                      onClick={() =>
                        setFormData((prev) => ({ ...prev, category: cat }))
                      }
                      className={cn(
                        "rounded-full px-4 py-1.5 text-sm font-medium transition-colors",
                        formData.category === cat
                          ? "bg-primary text-primary-foreground"
                          : "bg-secondary text-secondary-foreground"
                      )}
                    >
                      {categoryConfig[cat].label}
                    </button>
                  )
                )}
              </div>
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
              disabled={!formData.name.trim() || !formData.date}
            >
              保存
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
