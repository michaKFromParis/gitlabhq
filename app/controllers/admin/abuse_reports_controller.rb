class Admin::AbuseReportsController < Admin::ApplicationController
  def index
    @abuse_reports = AbuseReport.order(id: :desc).page(params[:page])
  end

  def destroy
<<<<<<< HEAD
    abuse_report = AbuseReport.find(params[:id])

    if params[:remove_user]
      abuse_report.user.destroy
    end

    abuse_report.destroy
    render nothing: true
=======
    AbuseReport.find(params[:id]).destroy

    redirect_to admin_abuse_reports_path, notice: 'Report was removed'
>>>>>>> master
  end
end
