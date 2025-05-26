import {
  Column,
  Entity,
  JoinTable,
  ManyToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { User } from '../../user/entities/user.entity';

@Entity()
export class Record {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  title: string;

  @Column()
  creator: number;

  @Column()
  from: Date;

  @Column()
  to: Date;

  @Column()
  description: string | null;

  @ManyToMany(() => User, (user) => user.records, {
    cascade: true,
  })
  @JoinTable({
    name: 'user_records',
    joinColumn: { name: 'record_id' },
    inverseJoinColumn: { name: 'user_id' },
  })
  participants: User[];
}
