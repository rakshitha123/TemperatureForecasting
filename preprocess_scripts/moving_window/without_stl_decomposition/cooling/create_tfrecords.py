from tfrecords_handler.moving_window.tfrecord_writer import TFRecordWriter
import os

txt_file_path = './datasets/text_data/moving_window/without_stl_decomposition/cooling/lecture_theatre/'
binary_file_path = './datasets/binary_data/moving_window/without_stl_decomposition/cooling/lecture_theatre/'
if not os.path.exists(binary_file_path):
    os.makedirs(binary_file_path)

if __name__ == '__main__':
    tfrecord_writer = TFRecordWriter(
        input_size = 2,
        output_size = 1,
        train_file_path = txt_file_path + 'full_cooling_1i1.txt',
        validate_file_path = txt_file_path + 'full_cooling_1i1v.txt',
        test_file_path = '',
        binary_train_file_path = binary_file_path + 'full_cooling_1i1.tfrecords',
        binary_validation_file_path = binary_file_path + 'full_cooling_1i1v.tfrecords',
        binary_test_file_path = ''
    )

    tfrecord_writer.read_text_data()
    tfrecord_writer.write_train_data_to_tfrecord_file()
    tfrecord_writer.write_validation_data_to_tfrecord_file()
