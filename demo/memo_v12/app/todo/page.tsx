"use client"

import { useState } from "react"
import { MobileLayout } from "@/components/mobile-layout"
import { TodoList } from "@/components/todo-list"
import { TodoDialog } from "@/components/todo-dialog"
import { Filter, Plus } from "lucide-react"
import { cn } from "@/lib/utils"

const categories = ["全部", "工作", "生活", "学习", "杂项"]

export interface Todo {
  id: string
  title: string
  category: string
  dueDate?: string
  note?: string
  completed: boolean
}

const initialTodos: Todo[] = [
  {
    id: "1",
    title: "完成项目报告",
    category: "工作",
    dueDate: "2026-03-20",
    completed: false,
  },
  {
    id: "2",
    title: "购买生活用品",
    category: "生活",
    dueDate: "2026-03-19",
    completed: false,
  },
  {
    id: "3",
    title: "复习英语单词",
    category: "学习",
    dueDate: "2026-03-18",
    completed: true,
  },
  {
    id: "4",
    title: "预约牙医",
    category: "生活",
    completed: false,
  },
]

export default function TodoPage() {
  const [activeCategory, setActiveCategory] = useState("全部")
  const [todos, setTodos] = useState<Todo[]>(initialTodos)
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingTodo, setEditingTodo] = useState<Todo | null>(null)

  const filteredTodos =
    activeCategory === "全部"
      ? todos
      : todos.filter((todo) => todo.category === activeCategory)

  const pendingTodos = filteredTodos.filter((t) => !t.completed)
  const completedTodos = filteredTodos.filter((t) => t.completed)

  const toggleTodo = (id: string) => {
    setTodos((prev) =>
      prev.map((todo) =>
        todo.id === id ? { ...todo, completed: !todo.completed } : todo
      )
    )
  }

  const saveTodo = (todo: Omit<Todo, "id" | "completed">) => {
    if (editingTodo) {
      setTodos((prev) =>
        prev.map((t) =>
          t.id === editingTodo.id ? { ...t, ...todo } : t
        )
      )
    } else {
      const newTodo: Todo = {
        ...todo,
        id: Date.now().toString(),
        completed: false,
      }
      setTodos((prev) => [...prev, newTodo])
    }
    setEditingTodo(null)
    setDialogOpen(false)
  }

  const deleteTodo = (id: string) => {
    setTodos((prev) => prev.filter((t) => t.id !== id))
  }

  const openEditDialog = (todo: Todo) => {
    setEditingTodo(todo)
    setDialogOpen(true)
  }

  return (
    <MobileLayout>
      <div className="flex flex-col">
        <header className="sticky top-0 z-40 border-b border-border bg-card/95 backdrop-blur-md">
          <div className="flex items-center justify-between px-4 py-3">
            <h1 className="text-xl font-semibold text-foreground">Todo</h1>
            <button className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground">
              <Filter className="h-5 w-5" />
            </button>
          </div>
          <div className="flex gap-2 overflow-x-auto px-4 pb-3 scrollbar-hide">
            {categories.map((cat) => (
              <button
                key={cat}
                onClick={() => setActiveCategory(cat)}
                className={cn(
                  "shrink-0 rounded-full px-4 py-1.5 text-sm font-medium transition-colors",
                  activeCategory === cat
                    ? "bg-primary text-primary-foreground"
                    : "bg-secondary text-secondary-foreground hover:bg-secondary/80"
                )}
              >
                {cat}
              </button>
            ))}
            <button className="shrink-0 rounded-full bg-secondary px-3 py-1.5 text-sm font-medium text-muted-foreground transition-colors hover:bg-secondary/80">
              <Plus className="h-4 w-4" />
            </button>
          </div>
        </header>

        <div className="flex-1 p-4">
          <TodoList
            title="待办"
            todos={pendingTodos}
            onToggle={toggleTodo}
            onEdit={openEditDialog}
            onDelete={deleteTodo}
          />
          {completedTodos.length > 0 && (
            <TodoList
              title="已完成"
              todos={completedTodos}
              onToggle={toggleTodo}
              onEdit={openEditDialog}
              onDelete={deleteTodo}
              collapsible
            />
          )}
        </div>

        <button
          onClick={() => {
            setEditingTodo(null)
            setDialogOpen(true)
          }}
          className="fixed bottom-24 right-4 z-40 flex h-14 w-14 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg transition-transform hover:scale-105 active:scale-95"
        >
          <Plus className="h-6 w-6" />
        </button>

        <TodoDialog
          open={dialogOpen}
          onOpenChange={setDialogOpen}
          todo={editingTodo}
          onSave={saveTodo}
        />
      </div>
    </MobileLayout>
  )
}
