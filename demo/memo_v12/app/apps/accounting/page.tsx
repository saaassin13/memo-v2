"use client"

import { useState } from "react"
import Link from "next/link"
import { ArrowLeft, BarChart3, Plus, TrendingUp, TrendingDown, Coffee, Car, ShoppingBag, Utensils, Home, Briefcase } from "lucide-react"
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

interface Transaction {
  id: string
  amount: number
  type: "income" | "expense"
  category: string
  note?: string
  date: string
}

const categories = [
  { id: "food", label: "餐饮", icon: Utensils },
  { id: "transport", label: "交通", icon: Car },
  { id: "shopping", label: "购物", icon: ShoppingBag },
  { id: "coffee", label: "饮品", icon: Coffee },
  { id: "home", label: "居家", icon: Home },
  { id: "work", label: "工资", icon: Briefcase },
]

const initialTransactions: Transaction[] = [
  { id: "1", amount: 35, type: "expense", category: "food", note: "午餐", date: "2026-03-18" },
  { id: "2", amount: 8000, type: "income", category: "work", note: "月工资", date: "2026-03-18" },
  { id: "3", amount: 120, type: "expense", category: "shopping", note: "日用品", date: "2026-03-17" },
  { id: "4", amount: 25, type: "expense", category: "coffee", date: "2026-03-17" },
  { id: "5", amount: 50, type: "expense", category: "transport", note: "打车", date: "2026-03-16" },
]

export default function AccountingPage() {
  const [transactions, setTransactions] = useState<Transaction[]>(initialTransactions)
  const [dialogOpen, setDialogOpen] = useState(false)
  const [formData, setFormData] = useState({
    amount: "",
    type: "expense" as "income" | "expense",
    category: "food",
    note: "",
  })

  const monthlyIncome = transactions
    .filter((t) => t.type === "income")
    .reduce((sum, t) => sum + t.amount, 0)
  const monthlyExpense = transactions
    .filter((t) => t.type === "expense")
    .reduce((sum, t) => sum + t.amount, 0)
  const balance = monthlyIncome - monthlyExpense

  const groupedByDate = transactions.reduce(
    (acc, t) => {
      if (!acc[t.date]) acc[t.date] = []
      acc[t.date].push(t)
      return acc
    },
    {} as Record<string, Transaction[]>
  )

  const handleSave = () => {
    if (!formData.amount) return
    const newTransaction: Transaction = {
      id: Date.now().toString(),
      amount: parseFloat(formData.amount),
      type: formData.type,
      category: formData.category,
      note: formData.note || undefined,
      date: new Date().toISOString().split("T")[0],
    }
    setTransactions((prev) => [newTransaction, ...prev])
    setDialogOpen(false)
    setFormData({ amount: "", type: "expense", category: "food", note: "" })
  }

  const getCategoryIcon = (categoryId: string) => {
    const cat = categories.find((c) => c.id === categoryId)
    return cat?.icon || Utensils
  }

  const getCategoryLabel = (categoryId: string) => {
    const cat = categories.find((c) => c.id === categoryId)
    return cat?.label || categoryId
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
          <h1 className="text-xl font-semibold text-foreground">记账</h1>
        </div>
        <button className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground">
          <BarChart3 className="h-5 w-5" />
        </button>
      </header>

      <div className="bg-card p-4">
        <h2 className="mb-3 text-sm font-medium text-muted-foreground">本月统计</h2>
        <div className="grid grid-cols-3 gap-3">
          <div className="rounded-xl bg-accent/10 p-3 text-center">
            <div className="flex items-center justify-center gap-1 text-accent">
              <TrendingUp className="h-4 w-4" />
              <span className="text-xs">收入</span>
            </div>
            <p className="mt-1 text-lg font-bold text-accent">
              {monthlyIncome.toLocaleString()}
            </p>
          </div>
          <div className="rounded-xl bg-destructive/10 p-3 text-center">
            <div className="flex items-center justify-center gap-1 text-destructive">
              <TrendingDown className="h-4 w-4" />
              <span className="text-xs">支出</span>
            </div>
            <p className="mt-1 text-lg font-bold text-destructive">
              {monthlyExpense.toLocaleString()}
            </p>
          </div>
          <div className="rounded-xl bg-primary/10 p-3 text-center">
            <div className="flex items-center justify-center gap-1 text-primary">
              <span className="text-xs">结余</span>
            </div>
            <p className="mt-1 text-lg font-bold text-primary">
              {balance.toLocaleString()}
            </p>
          </div>
        </div>
      </div>

      <div className="flex-1 p-4">
        {Object.entries(groupedByDate)
          .sort(([a], [b]) => b.localeCompare(a))
          .map(([date, items]) => (
            <div key={date} className="mb-6">
              <h3 className="mb-3 text-sm font-medium text-muted-foreground">
                {date}
              </h3>
              <div className="space-y-2">
                {items.map((t) => {
                  const Icon = getCategoryIcon(t.category)
                  return (
                    <div
                      key={t.id}
                      className="flex items-center gap-3 rounded-xl bg-card p-3 shadow-sm"
                    >
                      <div
                        className={cn(
                          "flex h-10 w-10 items-center justify-center rounded-xl",
                          t.type === "income"
                            ? "bg-accent/10 text-accent"
                            : "bg-muted text-muted-foreground"
                        )}
                      >
                        <Icon className="h-5 w-5" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="font-medium text-foreground">
                          {getCategoryLabel(t.category)}
                        </p>
                        {t.note && (
                          <p className="text-xs text-muted-foreground">{t.note}</p>
                        )}
                      </div>
                      <span
                        className={cn(
                          "font-semibold",
                          t.type === "income" ? "text-accent" : "text-foreground"
                        )}
                      >
                        {t.type === "income" ? "+" : "-"}
                        {t.amount.toLocaleString()}
                      </span>
                    </div>
                  )
                })}
              </div>
            </div>
          ))}
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
            <DialogTitle>记一笔</DialogTitle>
            <DialogDescription>记录收入或支出</DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="flex gap-2">
              <button
                onClick={() => setFormData((prev) => ({ ...prev, type: "expense" }))}
                className={cn(
                  "flex-1 rounded-lg py-2 text-sm font-medium transition-colors",
                  formData.type === "expense"
                    ? "bg-destructive/10 text-destructive"
                    : "bg-secondary text-secondary-foreground"
                )}
              >
                支出
              </button>
              <button
                onClick={() => setFormData((prev) => ({ ...prev, type: "income" }))}
                className={cn(
                  "flex-1 rounded-lg py-2 text-sm font-medium transition-colors",
                  formData.type === "income"
                    ? "bg-accent/10 text-accent"
                    : "bg-secondary text-secondary-foreground"
                )}
              >
                收入
              </button>
            </div>
            <div>
              <Input
                type="number"
                placeholder="金额"
                value={formData.amount}
                onChange={(e) =>
                  setFormData((prev) => ({ ...prev, amount: e.target.value }))
                }
                className="text-2xl font-bold text-center"
              />
            </div>
            <div>
              <label className="mb-2 block text-sm font-medium">分类</label>
              <div className="grid grid-cols-3 gap-2">
                {categories
                  .filter((c) =>
                    formData.type === "income"
                      ? c.id === "work"
                      : c.id !== "work"
                  )
                  .map((cat) => {
                    const Icon = cat.icon
                    return (
                      <button
                        key={cat.id}
                        onClick={() =>
                          setFormData((prev) => ({ ...prev, category: cat.id }))
                        }
                        className={cn(
                          "flex flex-col items-center gap-1 rounded-lg p-3 transition-colors",
                          formData.category === cat.id
                            ? "bg-primary text-primary-foreground"
                            : "bg-secondary text-secondary-foreground"
                        )}
                      >
                        <Icon className="h-5 w-5" />
                        <span className="text-xs">{cat.label}</span>
                      </button>
                    )
                  })}
              </div>
            </div>
            <div>
              <Textarea
                placeholder="备注（可选）"
                value={formData.note}
                onChange={(e) =>
                  setFormData((prev) => ({ ...prev, note: e.target.value }))
                }
                rows={2}
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
              disabled={!formData.amount}
            >
              保存
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
