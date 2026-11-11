# 代码注释规则

## 基本原则

**把用户当作熟练的开发人员**。不需要解释显而易见的代码逻辑。

## 不需要注释的情况

### 1. 逻辑显而易见

```python
# 不需要注释
def calculate_total(items):
    return sum(item.price for item in items)

# 不需要注释
if user.is_authenticated:
    show_dashboard()
else:
    redirect_to_login()
```

### 2. 函数名/变量名已说明意图

```python
# 不需要注释
def get_user_by_id(user_id):
    return db.query(User).filter_by(id=user_id).first()

# 不需要注释
active_users = [u for u in users if u.is_active]
```

### 3. 标准库/常用框架的常规用法

```python
# 不需要注释
with open('file.txt', 'r') as f:
    content = f.read()

# 不需要注释
@app.route('/api/users')
def list_users():
    return jsonify(users)
```

### 4. 简单的控制流程

```python
# 不需要注释
for item in items:
    process(item)

# 不需要注释
while queue.not_empty:
    handle(queue.pop())
```

## 需要注释的情况

### 1. 复杂逻辑

```python
# 需要注释：解释为什么这样做
def find_optimal_route(locations):
    # 使用动态规划求解 TSP 问题
    # 时间复杂度 O(n^2 * 2^n)，适用于 n <= 20 的场景
    ...
```

### 2. Hacky Workaround

```python
# 需要注释：解释问题、原因和临时方案
def connect_to_service():
    # FIXME: 服务端在高并发下会返回 503
    # 已报告给上游，临时增加重试逻辑
    # 相关 issue: https://github.com/xxx/issue/123
    for _ in range(3):
        try:
            return service.connect()
        except ServiceUnavailable:
            time.sleep(1)
    raise ConnectionError("Service unavailable after 3 retries")
```

### 3. 非直观的业务规则

```python
# 需要注释：解释业务规则
def calculate_discount(user, order):
    # VIP 用户在每月首单享受额外 10% 折扣
    # 折扣上限为订单金额的 50%
    if user.is_vip and order.is_first_of_month:
        discount = min(order.amount * 0.1, order.amount * 0.5)
        ...
```

### 4. 性能优化相关

```python
# 需要注释：解释优化原因和效果
def batch_process(items):
    # 批量处理减少数据库往返次数
    # 测试表明：1000 条数据从 2s 降至 50ms
    batch_size = 100
    for i in range(0, len(items), batch_size):
        db.bulk_insert(items[i:i+batch_size])
```

### 5. 依赖外部状态或副作用

```python
# 需要注释：说明外部依赖
def send_notification(user, message):
    # 依赖外部邮件服务，可能因网络问题失败
    # 调用方应处理可能的异常
    mail_service.send(user.email, message)
```

## 注释风格

### 好的注释

```python
# 使用二分查找优化搜索性能，O(log n) 替代 O(n)
index = bisect.bisect_left(sorted_list, target)

# 某些旧版浏览器不支持 fetch API，需要 polyfill
# 已在 IE11 上测试通过
```

### 不好的注释

```python
# 遍历列表
for item in items:
    # 处理每个项目
    process(item)

# 获取用户
user = get_user(id)  # 根据ID获取用户

# 返回结果
return result
```

## 判断标准

```
这段代码是否需要注释？
    ↓
逻辑是否显而易见？
    ├─ 是 → 不需要注释
    └─ 否 → 是否有清晰的命名？
              ├─ 是 → 不需要注释
              └─ 否 → 是否涉及复杂逻辑/hacky workaround？
                        ├─ 是 → 需要注释
                        └─ 否 → 考虑重构代码使其更清晰
```

## 总结

| 情况             | 是否需要注释 |
| ---------------- | ------------ |
| 简单逻辑         | ❌           |
| 清晰的命名       | ❌           |
| 标准库常规用法   | ❌           |
| 复杂算法         | ✅           |
| Hacky workaround | ✅           |
| 非直观业务规则   | ✅           |
| 性能优化         | ✅           |
| 外部依赖/副作用  | ✅           |
