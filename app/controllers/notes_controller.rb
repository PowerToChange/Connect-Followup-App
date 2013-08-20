class NotesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @note = Note.new(
      subject: Note.user_stamp(current_user),
      note: params[:note],
      contact_id: params[:contact_id]
    )

    if @note.save
      flash[:success] = t('notes.create.success')
    else
      flash[:error] = t('notes.create.error')
    end
  end

end