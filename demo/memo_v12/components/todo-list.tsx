"use client"

import { useState } from "react"
import type { Todo } from "@/app/todo/page"
import { cn } from "@/lib/utils"
import { Check, ChevronDown, MoreHorizontal, Trash2, Edit } from "lucide-react"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"

interface TodoListProps {
  title: string
  todos: Todo[]
  onToggle: (id: string) => void
  onEdit: (todo: Todo) => void
  onDelete: (id: string) => void
  collapsible?: boolean
}

const categoryColors: Record<string, string> = {
  工作: "bg-chart-1/10 text-chart-1",
  生活: "bg-accent/10 text-accent",
  学习: "bg-chart-3/10 text-chart-3",
  杂项: "bg-muted text-muted-foreground",
}

export function TodoList({
  title,
  todos,
  onToggle,
  onEdit,
  onDelete,
  collapsible = false,
}: TodoListProps) {
  const [collapsed, setCollapsed] = useState(false)

  if (todos.length === 0) return null

  return (
    <div className="mb-6">
      <button
        onClick={() => collapsible && setCollapsed(!collapsed)}
        className={cn(
          "mb-3 flex items-center gap-2 text-sm font-medium text-muted-foreground",
          collapsible && "cursor-pointer hover:text-foreground"
        )}
      >
        {collapsible && (
          <ChevronDown
            className={cn(
              "h-4 w-4 transition-transform",
              collapsed && "-rotate-90"
            )}
          />
        )}
        {title} ({todos.length})
      </button>
      {!collapsed && (
        <div className="space-y-2">
          {todos.map((todo) => (
            <div
              key={todo.id}
              className="flex items-start gap-3 rounded-xl bg-card p-4 shadow-sm"
            >
              <button
                onClick={() => onToggle(todo.id)}
                className={cn(
                  "mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full border-2 transition-colors",
                  todo.completed
                    ? "border-primary bg-primary text-primary-foreground"
                    : "border-muted-foreground/40 hover:border-primary"
                )}
              >
                {todo.completed && <Check className="h-3 w-3" />}
              </button>
              <div className="flex-1 min-w-0">
                <p
                  className={cn(
                    "font-medium text-foreground",
                    todo.completed && "text-muted-foreground line-through"
                  )}
                >
                  {todo.title}
                </p>
                <div className="mt-1 flex flex-wrap items-center gap-2">
                  <span
                    className={cn(
                      "rounded-full px-2 py-0.5 text-xs font-medium",
                      categoryColors[todo.category] || categoryColors["杂项"]
                    )}
                  >
                    {todo.category}
                  </span>
                  {todo.dueDate && (
                    <span className="text-xs text-muted-foreground">
                      {todo.dueDate}
                    </span>
                  )}
                </div>
              </div>
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <button className="rounded-full p-1 text-muted-foreground hover:bg-secondary hover:text-foreground">
                    <MoreHorizontal className="h-4 w-4" />
                  </button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                  <DropdownMenuItem onClick={() => onEdit(todo)}>
                    <Edit className="mr-2 h-4 w-4" />
                    编辑
                  </DropdownMenuItem>
                  <DropdownMenuItem
                    onClick={() => onDelete(todo.id)}
                    className="text-destructive focus:text-destructive"
                  >
                    <Trash2 className="mr-2 h-4 w-4" />
                    删除
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
