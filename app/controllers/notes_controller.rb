class NotesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @note = Note.new(
      subject: Note.user_stamp(current_user),
      note: params[:note],
      contact_id: params[:contact_id]
    )

    if @note.save
      flash[:success] = 'Note added.'
    else
      flash[:error] = 'Oops, could not add the note!'
    end
  end

end