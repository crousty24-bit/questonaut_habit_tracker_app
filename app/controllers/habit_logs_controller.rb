class HabitLogsController < ApplicationController
  before_action :set_habit_log, only: %i[ show edit update destroy ]

  # GET /habit_logs or /habit_logs.json
  def index
    @habit_logs = HabitLog.all
  end

  # GET /habit_logs/1 or /habit_logs/1.json
  def show
  end

  # GET /habit_logs/new
  def new
    @habit_log = HabitLog.new
  end

  # GET /habit_logs/1/edit
  def edit
  end

  # POST /habit_logs or /habit_logs.json
  def create
    @habit_log = HabitLog.new(habit_log_params)

    respond_to do |format|
      if @habit_log.save
        format.html { redirect_to @habit_log, notice: "Habit log was successfully created." }
        format.json { render :show, status: :created, location: @habit_log }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @habit_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /habit_logs/1 or /habit_logs/1.json
  def update
    respond_to do |format|
      if @habit_log.update(habit_log_params)
        format.html { redirect_to @habit_log, notice: "Habit log was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @habit_log }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @habit_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /habit_logs/1 or /habit_logs/1.json
  def destroy
    @habit_log.destroy!

    respond_to do |format|
      format.html { redirect_to habit_logs_path, notice: "Habit log was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_habit_log
      @habit_log = HabitLog.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def habit_log_params
      params.expect(habit_log: [ :date, :completed, :habit_id ])
    end
end
