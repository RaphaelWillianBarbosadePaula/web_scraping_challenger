class ScrapingJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: 3

  def perform(task_id)
    task = Task.find(task_id)

    task.update(status: 'processing')

    begin
      scraper = WebMotorsScraper.new(task.url)
      result = scraper.scrape

      if result.empty?
        raise "Não foi possível extrair os dados. A página pode ter bloqueado o acesso."
      end

      task.update!(
        status: 'concluded',
        result_data: result
      )

      NotificationClient.notify(
        task.id,
        task.user_id,
        'task_completed',
        { message: "Coleta finalizada para #{result[:model]}", data: result }
      )

    rescue StandardError => e
      task.update!(
        status: 'failed',
        result_data: { error: e.message }
      )

      NotificationClient.notify(
        task.id,
        task.user_id,
        'task_failed',
        { error: e.message, url: task.url }
      )
    end
  end
end