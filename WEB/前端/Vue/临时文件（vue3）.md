| 特性       | 描述                               | 注意 |     |
| ---------- | ---------------------------------- | ---- | --- |
| 插槽：slot | 父组件添加自定义的html内容到子组件；`<slot>`的html内容是默认值；[[#插槽：slot]] |      |     |

# 插槽：slot
ChildComp.vue
```html
<template>
  <slot>Fallback content</slot>
</template>
```

App.vue
```html
<script setup>
import { ref } from 'vue'
import ChildComp from './ChildComp.vue'

const msg = ref('from parent')
</script>

<template>
  <ChildComp>
    <p>
      你好slot插槽
    </p></ChildComp>
</template>
```