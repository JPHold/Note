# 纯原生js导入
```html
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title></title>
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

	</head>
	<body>
		<div id="app">{{message}}</div>
		<script>
			const {
				createApp
			} = Vue;
			createApp({
				data() {
					return {
						message: 'Hello Vue!'
					}
				}
			}).mount('#app')
		</script>
	</body>
</html>

```

# Es模块js导入
**注意`<script type="module">`，指定是模块**
```html
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title></title>
	</head>
	<body>
		<div id="app">{{message}}</div>
		<script type="module">
			import {createApp} from 'https://unpkg.com/vue@3/dist/vue.esm-browser.js';
			
			createApp({
				data() {
					return {
						message: 'Hello Vue!'
					}
				}
			}).mount('#app')
		</script>
	</body>
</html>

```