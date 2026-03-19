"use client"

import { useState, useEffect } from "react"
import type { Todo } from "@/app/todo/page"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"

interface TodoDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  todo: Todo | null
  onSave: (todo: Omit<Todo, "id" | "completed">) => void
}

const categories = ["工作", "生活", "学习", "杂项"]

export function TodoDialog({
  open,
  onOpenChange,
  todo,
  onSave,
}: TodoDialogProps) {
  const [title, setTitle] = useState("")
  const [category, setCategory] = useState("工作")
  const [dueDate, setDueDate] = useState("")
  const [note, setNote] = useState("")

  useEffect(() => {
    if (todo) {
      setTitle(todo.title)
      setCategory(todo.category)
      setDueDate(todo.dueDate || "")
      setNote(todo.note || "")
    } else {
      setTitle("")
      setCategory("工作")
      setDueDate("")
      setNote("")
    }
  }, [todo, open])

  const handleSave = () => {
    if (!title.trim()) return
    onSave({
      title: title.trim(),
      category,
      dueDate: dueDate || undefined,
      note: note.trim() || undefined,
    })
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-[calc(100vw-2rem)] rounded-2xl sm:max-w-md">
        <DialogHeader>
          <DialogTitle>{todo ? "编辑任务" : "新建任务"}</DialogTitle>
          <DialogDescription>
            {todo ? "修改任务的详细信息" : "填写任务的详细信息"}
          </DialogDescription>
        </DialogHeader>
        <div className="space-y-4 py-4">
          <div>
            <Input
              placeholder="任务标题"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="text-base"
            />
          </div>
          <div>
            <label className="mb-2 block text-sm font-medium text-foreground">
              分类
            </label>
            <div className="flex flex-wrap gap-2">
              {categories.map((cat) => (
                <button
                  key={cat}
                  onClick={() => setCategory(cat)}
                  className={cn(
                    "rounded-full px-4 py-1.5 text-sm font-medium transition-colors",
                    category === cat
                      ? "bg-primary text-primary-foreground"
                      : "bg-secondary text-secondary-foreground hover:bg-secondary/80"
                  )}
                >
                  {cat}
                </button>
              ))}
            </div>
          </div>
          <div>
            <label className="mb-2 block text-sm font-medium text-foreground">
              截止日期
            </label>
            <Input
              type="date"
              value={dueDate}
              onChange={(e) => setDueDate(e.target.value)}
            />
          </div>
          <div>
            <label className="mb-2 block text-sm font-medium text-foreground">
              备注
            </label>
            <Textarea
              placeholder="添加备注..."
              value={note}
              onChange={(e) => setNote(e.target.value)}
              rows={3}
            />
          </div>
        </div>
        <div className="flex gap-3">
          <Button
            variant="outline"
            className="flex-1"
            onClick={() => onOpenChange(false)}
          >
            取消
          </Button>
          <Button className="flex-1" onClick={handleSave} disabled={!title.trim()}>
            保存
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}
