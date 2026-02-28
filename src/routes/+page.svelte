<script>
  let todos = [];
  let nextId = 1;
  let newText = '';
  let editText = '';

  $: remaining = todos.filter(t => !t.completed).length;

  function addTodo() {
    const trimmed = newText.trim();
    if (!trimmed) return;
    todos = [...todos, { id: nextId++, text: trimmed, completed: false, isEditing: false }];
    newText = '';
  }

  function handleAddKeydown(e) {
    if (e.key === 'Enter') addTodo();
  }

  function toggleCompleted(id) {
    todos = todos.map(t => t.id === id ? { ...t, completed: !t.completed } : t);
  }

  function deleteTodo(id) {
    todos = todos.filter(t => t.id !== id);
  }

  function startEditing(todo) {
    editText = todo.text;
    todos = todos.map(t => ({ ...t, isEditing: t.id === todo.id }));
  }

  function saveEdit(id) {
    const trimmed = editText.trim();
    if (!trimmed) return;
    todos = todos.map(t => t.id === id ? { ...t, text: trimmed, isEditing: false } : t);
    editText = '';
  }

  function cancelEdit(id) {
    todos = todos.map(t => t.id === id ? { ...t, isEditing: false } : t);
    editText = '';
  }

  function handleEditKeydown(e, id) {
    if (e.key === 'Enter') saveEdit(id);
    if (e.key === 'Escape') cancelEdit(id);
  }

  function clearCompleted() {
    todos = todos.filter(t => !t.completed);
  }
</script>

<div class="container">
  <h1>Todo App</h1>

  <div class="add-row">
    <input
      type="text"
      placeholder="What needs to be done?"
      bind:value={newText}
      on:keydown={handleAddKeydown}
    />
    <button on:click={addTodo}>Add</button>
  </div>

  {#if todos.length > 0}
    <ul>
      {#each todos as todo (todo.id)}
        <li class:completed={todo.completed}>
          <input
            type="checkbox"
            checked={todo.completed}
            on:change={() => toggleCompleted(todo.id)}
          />

          {#if todo.isEditing}
            <input
              class="edit-input"
              type="text"
              bind:value={editText}
              on:keydown={(e) => handleEditKeydown(e, todo.id)}
            />
            <button on:click={() => saveEdit(todo.id)}>Save</button>
            <button on:click={() => cancelEdit(todo.id)}>Cancel</button>
          {:else}
            <span class="todo-text">{todo.text}</span>
            <button on:click={() => startEditing(todo)}>Edit</button>
            <button on:click={() => deleteTodo(todo.id)}>Delete</button>
          {/if}
        </li>
      {/each}
    </ul>

    <div class="footer">
      <span>{remaining} {remaining === 1 ? 'item' : 'items'} left</span>
      <button on:click={clearCompleted}>Clear completed todos</button>
    </div>
  {:else}
    <p class="empty">No todos yet. Add one above!</p>
  {/if}
</div>

<style>
  .container {
    max-width: 540px;
    margin: 2rem auto;
    font-family: sans-serif;
  }

  h1 {
    text-align: center;
    margin-bottom: 1.5rem;
  }

  .add-row {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 1rem;
  }

  .add-row input {
    flex: 1;
    padding: 0.5rem 0.75rem;
    font-size: 1rem;
    border: 1px solid #ccc;
    border-radius: 4px;
  }

  ul {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  li {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 0;
    border-bottom: 1px solid #eee;
  }

  .todo-text {
    flex: 1;
  }

  li.completed .todo-text {
    text-decoration: line-through;
    color: #999;
  }

  .edit-input {
    flex: 1;
    padding: 0.25rem 0.5rem;
    font-size: 1rem;
    border: 1px solid #aaa;
    border-radius: 4px;
  }

  button {
    padding: 0.35rem 0.75rem;
    font-size: 0.875rem;
    cursor: pointer;
    border: 1px solid #ccc;
    border-radius: 4px;
    background: #fff;
  }

  button:hover {
    background: #f0f0f0;
  }

  .footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 1rem;
    font-size: 0.875rem;
    color: #555;
  }

  .empty {
    text-align: center;
    color: #aaa;
  }
</style>
