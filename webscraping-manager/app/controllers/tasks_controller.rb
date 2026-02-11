class TasksController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:create, :update, :destroy]
  before_action :set_task, only: [:show, :update, :destroy, :edit]

  def index
    @tasks = Task.where(user_id: current_user.id).order(created_at: :desc)
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.user_id = current_user.id

    if @task.save
      NotificationClient.notify(@task.id, @task.user_id, 'task_created', { url: @task.url })
      redirect_to tasks_path, notice: 'Tarefa criada!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @task
    @notifications = NotificationClient.get_by_task(@task.id)
  end

  def edit
    @task
  end

  def update
    if @task.update(task_params)
      redirect_to tasks_path, notice: 'Tarefa atualizada!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    task_id = @task.id
    user_id = @task.user_id
    task_url = @task.url

    if @task.destroy
      redirect_to tasks_path, notice: 'Tarefa deletada!', status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_task
    @task = Task.find_by!(id: params[:id], user_id: current_user.id)
  rescue ActiveRecord::RecordNotFound
    redirect_to tasks_path, alert: "Tarefa não encontrada ou acesso negado."
  end

  def task_params
    params.require(:task).permit(:title, :url)
  end
end