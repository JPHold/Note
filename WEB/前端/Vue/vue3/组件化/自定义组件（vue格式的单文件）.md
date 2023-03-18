[TOC]
* 利用[@vue/compiler-sfc](https://github.com/vuejs/core/tree/main/packages/compiler-sfc)预编译成标准的JavaScript和css |

* Single File component（简称：SFC）
**需要使用构建工具，才能使用SFC**

# script、template、style的组合方式

## 都放在一个.vue文件里

## 分开存放，再导入
[资源导入](https://cn.vuejs.org/api/sfc-spec.html#src-imports)



# API书写方式
## 选项式（实例-属性）
基于[[#组合式（直接按以前js的书写方式）]]，只是做了层封装

```js
<script>
export default {
  // data() 返回的属性将会成为响应式的状态
  // 并且暴露在 `this` 上
  data() {
    return {
      count: 0
    }
  },

  // methods 是一些用来更改状态与触发更新的函数
  // 它们可以在模板中作为事件监听器绑定
  methods: {
    increment() {
      this.count++
    }
  },

  // 生命周期钩子会在组件生命周期的各个不同阶段被调用
  // 例如这个函数就会在组件挂载完成后被调用
  mounted() {
    console.log(`The initial count is ${this.count}.`)
  }
}
</script>

<template>
  <button @click="increment">Count is: {{ count }}</button>
</template>
```

## 组合式（直接按以前js的书写方式）
使用了import，将vue.js的函数导入使用

```js
<script setup>
import { ref, onMounted } from 'vue'

// 响应式状态
const count = ref(0)

// 用来修改状态、触发更新的函数
function increment() {
  count.value++
}

// 生命周期钩子
onMounted(() => {
  console.log(`The initial count is ${count.value}.`)
})
</script>

<template>
  <button @click="increment">Count is: {{ count }}</button>
</template>
```

## 如何选择
使用[[#选项式（实例-属性）]]
1. 初学者
2. 只是用vue当作辅助，做渐进式增强
3. 用于低复杂度的场景

使用[[#组合式（直接按以前js的书写方式）]]
1. 熟练者，对响应式有深度了解
2. 完全采用vue做完成单页应用
3. .用于高复杂度的场景